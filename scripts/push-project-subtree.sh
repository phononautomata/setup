#!/bin/sh

# Add files from one MotokoKusanagi project subtree to the same subtree on
# BigBlue. Existing destination files are never overwritten and nothing is
# deleted. Preview is the default; --apply is required to copy.

set -eu

mode=preview
if [ "${1:-}" = "--apply" ]; then
  mode=apply
  shift
fi

if [ "$#" -ne 2 ]; then
  printf 'usage: %s [--apply] PROJECT RELATIVE_SUBTREE\n' "$0" >&2
  exit 2
fi

project="$1"
subtree="$2"

case "$project" in
  ''|.|..|*[!A-Za-z0-9._-]*)
    printf 'error: unsupported project name: %s\n' "$project" >&2
    exit 2
    ;;
esac

case "$subtree" in
  ''|.|..|/*|*/../*|../*|*/..|*[!A-Za-z0-9._/-]*)
    printf 'error: subtree must be a safe relative path: %s\n' "$subtree" >&2
    exit 2
    ;;
esac

local_root="${LOCAL_WORKSHOP_ROOT:-"$HOME/workshop"}"
remote_host="${BIGBLUE_SSH_HOST:-"ademiguel@bigblue"}"
remote_root="${BIGBLUE_WORKSHOP_ROOT:-"/Users/ademiguel/workshop"}"
log_root="${WORKSHOP_TRANSFER_LOG_ROOT:-"$HOME/workshop-transfer-logs"}"

local_project="$local_root/$project"
local_source="$local_project/$subtree"
remote_project="$remote_root/$project"
remote_destination="$remote_project/$subtree"

if [ ! -d "$local_source" ]; then
  printf 'error: source subtree not found: %s\n' "$local_source" >&2
  exit 1
fi

if ! ssh -n -o BatchMode=yes "$remote_host" /bin/test -d "$remote_project"; then
  printf 'error: BigBlue project not found: %s\n' "$remote_project" >&2
  exit 1
fi

timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
safe_subtree="$(printf '%s' "$subtree" | tr '/' '_')"
log_file="$log_root/${timestamp}-${mode}-${project}-${safe_subtree}.log"

mkdir -p "$log_root"
chmod 700 "$log_root"

{
  printf '# timestamp\t%s\n' "$timestamp"
  printf '# mode\t%s\n' "$mode"
  printf '# policy\tadd-missing-only; no overwrite; no delete\n'
  printf '# source\t%s\n' "$local_source/"
  printf '# destination\t%s:%s\n' "$remote_host" "$remote_destination/"
} > "$log_file"

printf 'mode:         %s\n' "$mode"
printf 'policy:       add missing files only; no overwrite; no delete\n'
printf 'source:       %s\n' "$local_source/"
printf 'destination:  %s:%s\n' "$remote_host" "$remote_destination/"
printf 'log:          %s\n\n' "$log_file"

if [ "$mode" = apply ]; then
  ssh -n -o BatchMode=yes "$remote_host" /bin/mkdir -p "$remote_destination"
  rsync_options='-aivh'
else
  rsync_options='-anivh'
fi

set +e
# shellcheck disable=SC2086
/usr/bin/rsync \
  $rsync_options \
  --ignore-existing \
  --partial \
  --exclude='.DS_Store' \
  "$local_source/" \
  "$remote_host:$remote_destination/" \
  >> "$log_file" 2>&1
rsync_status=$?
set -e

cat "$log_file"

if [ "$rsync_status" -ne 0 ]; then
  printf 'error: rsync exited with status %s\n' "$rsync_status" >&2
  exit "$rsync_status"
fi

if [ "$mode" = preview ]; then
  printf '\nPreview complete. Re-run with --apply after reviewing this log.\n'
else
  printf '\nTransfer complete. Existing BigBlue files were retained.\n'
fi
