#!/bin/sh

# Compare Git metadata for same-named top-level projects on MotokoKusanagi and
# BigBlue. Run this script on MotokoKusanagi. It reads repository metadata only.

set -eu

local_root="${LOCAL_WORKSHOP_ROOT:-"$HOME/workshop"}"
remote_host="${BIGBLUE_SSH_HOST:-"ademiguel@bigblue"}"
remote_root="${BIGBLUE_WORKSHOP_ROOT:-"/Users/ademiguel/workshop"}"
remote_git="${BIGBLUE_GIT:-"/usr/bin/git"}"
remote_test="${BIGBLUE_TEST:-"/bin/test"}"

if [ ! -d "$local_root" ]; then
  printf 'error: local workshop root not found: %s\n' "$local_root" >&2
  exit 1
fi

if ! ssh -o BatchMode=yes "$remote_host" "$remote_test" -d "$remote_root"; then
  printf 'error: cannot verify BigBlue workshop root: %s\n' "$remote_root" >&2
  exit 1
fi

printf '# local_root\t%s\n' "$local_root"
printf '# remote\t%s:%s\n' "$remote_host" "$remote_root"
printf 'project\tlocal_branch\tlocal_head\tlocal_dirty\tremote_branch\tremote_head\tremote_dirty\thead_match\torigin_match\n'

find "$local_root" -mindepth 1 -maxdepth 1 -type d -print |
  LC_ALL=C sort |
  while IFS= read -r local_project; do
    project="$(basename "$local_project")"

    case "$project" in
      ''|*[!A-Za-z0-9._-]*)
        printf 'warning: skipped unsupported project name: %s\n' "$project" >&2
        continue
        ;;
    esac

    if [ ! -d "$local_project/.git" ] && [ ! -f "$local_project/.git" ]; then
      continue
    fi

    remote_project="$remote_root/$project"

    if ! ssh -o BatchMode=yes "$remote_host" \
      "$remote_test" -e "$remote_project/.git"; then
      continue
    fi

    local_branch="$(git -C "$local_project" branch --show-current 2>/dev/null || true)"
    [ -n "$local_branch" ] || local_branch='(detached-or-unborn)'
    local_head="$(git -C "$local_project" rev-parse HEAD 2>/dev/null || printf none)"
    if [ -n "$(git -C "$local_project" status --porcelain 2>/dev/null)" ]; then
      local_dirty=yes
    else
      local_dirty=no
    fi
    local_origin="$(git -C "$local_project" remote get-url origin 2>/dev/null || printf none)"

    # Invoke concrete executables directly. Avoid compound remote shell syntax
    # so the comparison is independent of BigBlue's interactive login shell.
    remote_branch="$(ssh -o BatchMode=yes "$remote_host" \
      "$remote_git" -C "$remote_project" branch --show-current 2>/dev/null || true)"
    [ -n "$remote_branch" ] || remote_branch='(detached-or-unborn)'
    remote_head="$(ssh -o BatchMode=yes "$remote_host" \
      "$remote_git" -C "$remote_project" rev-parse HEAD 2>/dev/null || printf none)"
    remote_status="$(ssh -o BatchMode=yes "$remote_host" \
      "$remote_git" -C "$remote_project" status --porcelain 2>/dev/null || true)"
    if [ -n "$remote_status" ]; then
      remote_dirty=yes
    else
      remote_dirty=no
    fi
    remote_origin="$(ssh -o BatchMode=yes "$remote_host" \
      "$remote_git" -C "$remote_project" remote get-url origin 2>/dev/null || printf none)"

    if [ "$local_head" = "$remote_head" ]; then
      head_match=yes
    else
      head_match=no
    fi

    if [ "$local_origin" = "$remote_origin" ]; then
      origin_match=yes
    else
      origin_match=no
    fi

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$project" "$local_branch" "$local_head" "$local_dirty" \
      "$remote_branch" "$remote_head" "$remote_dirty" "$head_match" "$origin_match"
  done
