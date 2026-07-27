#!/bin/sh

# Report structural metadata for each top-level workshop entry. This script
# never reads file contents and does not modify projects.

set -u

workshop_root="${1:-"$HOME/workshop"}"

if [ ! -d "$workshop_root" ]; then
  printf 'error: workshop root does not exist: %s\n' "$workshop_root" >&2
  exit 1
fi

machine="$(scutil --get ComputerName 2>/dev/null || hostname)"

printf '# machine\t%s\n' "$machine"
printf '# root\t%s\n' "$workshop_root"
printf '# generated\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

if [ -d "$workshop_root/.git" ] || [ -f "$workshop_root/.git" ]; then
  root_branch="$(git -C "$workshop_root" branch --show-current 2>/dev/null || true)"
  [ -n "$root_branch" ] || root_branch='(detached-or-unborn)'
  root_remote="$(git -C "$workshop_root" remote get-url origin 2>/dev/null || printf none)"
  root_tracked="$(git -C "$workshop_root" ls-files 2>/dev/null | wc -l | tr -d ' ')"
  printf '# root_git\tyes\n'
  printf '# root_git_branch\t%s\n' "$root_branch"
  printf '# root_git_origin\t%s\n' "$root_remote"
  printf '# root_git_tracked_files\t%s\n' "$root_tracked"
  printf 'warning: workshop root is itself a Git repository; inspect before transfer\n' >&2
else
  printf '# root_git\tno\n'
fi

printf 'entry\ttype\tsize_mib\tgit\tbranch\tdirty\tremote_host\tremote_path\tarchives\tlarge_files\n'

find "$workshop_root" -mindepth 1 -maxdepth 1 -print |
  LC_ALL=C sort |
  while IFS= read -r entry_path; do
    entry_name="$(basename "$entry_path")"

    if [ -d "$entry_path" ]; then
      entry_type=directory
    elif [ -f "$entry_path" ]; then
      entry_type=file
    else
      entry_type=other
    fi

    size_kib="$(du -sk "$entry_path" 2>/dev/null | awk '{print $1}')"
    size_mib="$(( ${size_kib:-0} / 1024 ))"

    git_state=no
    branch=-
    dirty=-
    remote_host=-
    remote_path=-

    if [ -d "$entry_path/.git" ] || [ -f "$entry_path/.git" ]; then
      git_state=yes
      branch="$(git -C "$entry_path" branch --show-current 2>/dev/null || true)"
      [ -n "$branch" ] || branch='(detached-or-unborn)'

      if [ -n "$(git -C "$entry_path" status --porcelain 2>/dev/null)" ]; then
        dirty=yes
      else
        dirty=no
      fi

      remote_url="$(git -C "$entry_path" remote get-url origin 2>/dev/null || true)"
      case "$remote_url" in
        git@*:*/*)
          remote_host="$(printf '%s\n' "$remote_url" | sed 's/^git@//;s/:.*$//')"
          remote_path="$(printf '%s\n' "$remote_url" | sed 's/^[^:]*://;s/\.git$//')"
          ;;
        http://*|https://*)
          remote_host="$(printf '%s\n' "$remote_url" | sed 's|^[a-z]*://||;s|/.*$||')"
          remote_path="$(printf '%s\n' "$remote_url" | sed 's|^[a-z]*://[^/]*/||;s|\.git$||')"
          ;;
        '')
          ;;
        *)
          remote_host=other
          remote_path=local-or-nonstandard
          ;;
      esac
    fi

    if [ -d "$entry_path" ]; then
      archives="$(find "$entry_path" -type f \
        \( -iname '*.zip' -o -iname '*.tar' -o -iname '*.tgz' \
        -o -iname '*.tar.gz' -o -iname '*.tar.bz2' -o -iname '*.tar.xz' \
        -o -iname '*.7z' -o -iname '*.rar' \) 2>/dev/null |
        wc -l |
        tr -d ' ')"
      large_files="$(find "$entry_path" -type f -size +100M 2>/dev/null |
        wc -l |
        tr -d ' ')"
    else
      archives=0
      if [ -f "$entry_path" ] && [ "$(stat -f '%z' "$entry_path" 2>/dev/null || printf 0)" -gt 104857600 ]; then
        large_files=1
      else
        large_files=0
      fi
    fi

    # Tabs and newlines in top-level names would corrupt TSV output. Represent
    # them visibly rather than attempting to interpret them.
    safe_name="$(printf '%s' "$entry_name" | tr '\t\n' '__')"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$safe_name" "$entry_type" "$size_mib" "$git_state" "$branch" "$dirty" \
      "$remote_host" "$remote_path" "$archives" "$large_files"
  done
