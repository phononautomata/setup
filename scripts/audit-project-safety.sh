#!/bin/sh

# Read-only Git safety report for workshop projects. It reports counts and
# branch relationships without printing filenames or reading file contents.

set -u

root="${WORKSHOP_ROOT:-$HOME/workshop}"

if [ ! -d "$root" ]; then
  printf 'Workshop root not found: %s\n' "$root" >&2
  exit 1
fi

printf '# machine\t%s\n' "$(scutil --get ComputerName 2>/dev/null || hostname)"
printf '# root\t%s\n' "$root"
printf '# generated\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf 'project\tbranch\tstaged\tunstaged\tuntracked\tupstream\tahead\tbehind\torigin\n'

report_project() {
  project="$1"
  path="$root/$project"

  if [ ! -d "$path/.git" ] && [ ! -f "$path/.git" ]; then
    printf '%s\t-\t-\t-\t-\t-\t-\t-\tnot-a-repository\n' "$project"
    return
  fi

  branch="$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null ||
    printf detached)"

  counts="$(git -C "$path" status --porcelain=v2 2>/dev/null |
    awk '
      BEGIN { staged = 0; unstaged = 0; untracked = 0 }
      /^\?/ { untracked++; next }
      /^[12u] / {
        xy = $2
        if (substr(xy, 1, 1) != ".") staged++
        if (substr(xy, 2, 1) != ".") unstaged++
      }
      END { printf "%d\t%d\t%d", staged, unstaged, untracked }
    ')"

  upstream="$(git -C "$path" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null ||
    printf none)"
  ahead='-'
  behind='-'
  if [ "$upstream" != none ]; then
    relation="$(git -C "$path" rev-list --left-right --count \
      "$upstream...HEAD" 2>/dev/null || printf '-\t-')"
    behind="$(printf '%s\n' "$relation" | awk '{print $1}')"
    ahead="$(printf '%s\n' "$relation" | awk '{print $2}')"
  fi

  if git -C "$path" remote get-url origin >/dev/null 2>&1; then
    origin='yes'
  else
    origin='no'
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$project" "$branch" "$counts" "$upstream" "$ahead" "$behind" "$origin"
}

if [ "$#" -gt 0 ]; then
  for project in "$@"; do
    case "$project" in
      ''|*/*|.|..) printf 'Invalid project name: %s\n' "$project" >&2; exit 2 ;;
    esac
    report_project "$project"
  done
else
  find "$root" -mindepth 1 -maxdepth 1 -type d -print |
    LC_ALL=C sort |
    while IFS= read -r path; do
      project="$(basename "$path")"
      if [ -d "$path/.git" ] || [ -f "$path/.git" ]; then
        report_project "$project"
      fi
    done
fi

