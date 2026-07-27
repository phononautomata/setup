#!/bin/sh

# Compare Git metadata for same-named top-level projects on MotokoKusanagi and
# BigBlue. Run this script on MotokoKusanagi. It reads repository metadata only.

set -eu

local_root="${LOCAL_WORKSHOP_ROOT:-"$HOME/workshop"}"
remote_host="${BIGBLUE_SSH_HOST:-"ademiguel@bigblue"}"
remote_root="${BIGBLUE_WORKSHOP_ROOT:-"/Users/ademiguel/workshop"}"

if [ ! -d "$local_root" ]; then
  printf 'error: local workshop root not found: %s\n' "$local_root" >&2
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

    if ! ssh -o BatchMode=yes "$remote_host" \
      "test -d '$remote_root/$project/.git' -o -f '$remote_root/$project/.git'"; then
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

    remote_record="$(ssh -o BatchMode=yes "$remote_host" \
      "project='$remote_root/$project'
       branch=\$(git -C \"\$project\" branch --show-current 2>/dev/null)
       test -n \"\$branch\" || branch='(detached-or-unborn)'
       head=\$(git -C \"\$project\" rev-parse HEAD 2>/dev/null || printf none)
       if test -n \"\$(git -C \"\$project\" status --porcelain 2>/dev/null)\"; then dirty=yes; else dirty=no; fi
       origin=\$(git -C \"\$project\" remote get-url origin 2>/dev/null || printf none)
       printf '%s\\t%s\\t%s\\t%s\\n' \"\$branch\" \"\$head\" \"\$dirty\" \"\$origin\"")"

    remote_branch="$(printf '%s\n' "$remote_record" | awk -F '\t' '{print $1}')"
    remote_head="$(printf '%s\n' "$remote_record" | awk -F '\t' '{print $2}')"
    remote_dirty="$(printf '%s\n' "$remote_record" | awk -F '\t' '{print $3}')"
    remote_origin="$(printf '%s\n' "$remote_record" | awk -F '\t' '{print $4}')"

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
