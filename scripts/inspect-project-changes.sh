#!/bin/sh

# Read-only detailed Git inspection for explicitly named workshop projects.
# Unlike audit-project-safety.sh, this prints changed and untracked filenames.

set -u

root="${WORKSHOP_ROOT:-$HOME/workshop}"

if [ "$#" -eq 0 ]; then
  printf 'Usage: %s PROJECT [PROJECT ...]\n' "$0" >&2
  exit 2
fi

for project in "$@"; do
  case "$project" in
    ''|*/*|.|..)
      printf 'Invalid project name: %s\n' "$project" >&2
      exit 2
      ;;
  esac

  path="$root/$project"
  if [ ! -d "$path/.git" ] && [ ! -f "$path/.git" ]; then
    printf 'Not a Git repository: %s\n' "$path" >&2
    continue
  fi

  printf '## %s\n' "$project"
  git -C "$path" remote -v 2>/dev/null || true
  git -C "$path" status --short --branch

  printf '%s\n' '-- commits not on configured upstream --'
  if git -C "$path" rev-parse --verify '@{upstream}' >/dev/null 2>&1; then
    git -C "$path" log --oneline --decorate '@{upstream}..HEAD'
  else
    printf 'no-valid-upstream\n'
  fi

  printf '%s\n' '-- changed paths --'
  git -C "$path" status --short

  printf '%s\n' '-- unstaged summary --'
  git -C "$path" diff --stat

  printf '%s\n' '-- staged summary --'
  git -C "$path" diff --cached --stat
  printf '\n'
done

