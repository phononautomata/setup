#!/bin/sh

# Preview file-level differences from MotokoKusanagi to BigBlue for one
# same-named project. This script is permanently dry-run and cannot copy or
# delete files.

set -eu

full=no
if [ "${1:-}" = "--full" ]; then
  full=yes
  shift
fi

if [ "$#" -ne 1 ]; then
  printf 'usage: %s [--full] PROJECT\n' "$0" >&2
  exit 2
fi

project="$1"
case "$project" in
  ''|.|..|*[!A-Za-z0-9._-]*)
    printf 'error: unsupported project name: %s\n' "$project" >&2
    exit 2
    ;;
esac

local_root="${LOCAL_WORKSHOP_ROOT:-"$HOME/workshop"}"
remote_host="${BIGBLUE_SSH_HOST:-"ademiguel@bigblue"}"
remote_root="${BIGBLUE_WORKSHOP_ROOT:-"/Users/ademiguel/workshop"}"
local_project="$local_root/$project"
remote_project="$remote_root/$project"

if [ ! -d "$local_project" ]; then
  printf 'error: local project not found: %s\n' "$local_project" >&2
  exit 1
fi

if ! ssh -n -o BatchMode=yes "$remote_host" /bin/test -d "$remote_project"; then
  printf 'error: BigBlue project not found: %s\n' "$remote_project" >&2
  exit 1
fi

printf '# mode\tdry-run-only\n'
printf '# source\t%s\n' "$local_project/"
printf '# destination\t%s:%s\n' "$remote_host" "$remote_project/"
printf '# direction\tMotokoKusanagi -> BigBlue\n'
printf '# note\tdeleting markers identify BigBlue-only paths; nothing is deleted\n'

if [ "$full" = yes ]; then
  printf '# view\tfull\n'
  /usr/bin/rsync \
    -aniv \
    --delete \
    --exclude='.git/' \
    --exclude='.DS_Store' \
    "$local_project/" \
    "$remote_host:$remote_project/"
else
  printf '# view\tresearch-state (tracked files and reproducible environments/builds excluded)\n'

  exclude_file="$(mktemp "${TMPDIR:-/tmp}/workshop-tracked.XXXXXX")"
  trap 'rm -f "$exclude_file"' EXIT HUP INT TERM

  if [ -d "$local_project/.git" ] || [ -f "$local_project/.git" ]; then
    git -C "$local_project" ls-files | sed 's|^|/|' > "$exclude_file"
  fi

  /usr/bin/rsync \
    -aniv \
    --delete \
    --exclude-from="$exclude_file" \
    --exclude='.git/' \
    --exclude='.DS_Store' \
    --exclude='.venv/' \
    --exclude='venv/' \
    --exclude='.nagare/' \
    --exclude='target/' \
    --exclude='__pycache__/' \
    --exclude='.pytest_cache/' \
    --exclude='.mypy_cache/' \
    --exclude='.ruff_cache/' \
    --exclude='*.pyc' \
    "$local_project/" \
    "$remote_host:$remote_project/"
fi
