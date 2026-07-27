#!/bin/sh

# Reversibly detach an unintended Git repository at ~/workshop while leaving
# every workshop file and nested project repository untouched.

set -eu

mode=preview
if [ "${1:-}" = "--apply" ]; then
  mode=apply
elif [ "$#" -ne 0 ]; then
  printf 'usage: %s [--apply]\n' "$0" >&2
  exit 2
fi

workshop_root="$HOME/workshop"
git_dir="$workshop_root/.git"
archive_parent="$HOME/workshop-metadata-archive"
timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
archive_dir="$archive_parent/workshop-parent-git-$timestamp"

if [ ! -d "$git_dir" ]; then
  printf 'error: expected Git directory not found: %s\n' "$git_dir" >&2
  exit 1
fi

top_level="$(git -C "$workshop_root" rev-parse --show-toplevel 2>/dev/null)"
if [ "$top_level" != "$workshop_root" ]; then
  printf 'error: Git top level is not the expected workshop root\n' >&2
  printf 'expected: %s\nactual:   %s\n' "$workshop_root" "$top_level" >&2
  exit 1
fi

tracked_count="$(git -C "$workshop_root" ls-files | wc -l | tr -d ' ')"
remote="$(git -C "$workshop_root" remote get-url origin 2>/dev/null || printf none)"

printf 'mode:            %s\n' "$mode"
printf 'workshop:        %s\n' "$workshop_root"
printf 'tracked files:   %s\n' "$tracked_count"
printf 'origin:          %s\n' "$remote"
printf 'Git metadata:    %s\n' "$git_dir"
printf 'archive target:  %s\n' "$archive_dir"
printf '\nNo workshop files or nested repositories will be moved.\n'

if [ "$mode" = preview ]; then
  printf '\nPreview only. Re-run with --apply to create the archive and detach the parent repository.\n'
  exit 0
fi

if [ -e "$archive_dir" ]; then
  printf 'error: archive target already exists: %s\n' "$archive_dir" >&2
  exit 1
fi

mkdir -p "$archive_dir"
chmod 700 "$archive_parent" "$archive_dir"

git -C "$workshop_root" remote -v > "$archive_dir/remotes.txt"
git -C "$workshop_root" log --oneline --decorate --all > "$archive_dir/log.txt"
git -C "$workshop_root" ls-tree -rl HEAD > "$archive_dir/head-tree.txt"
git -C "$workshop_root" status --short --untracked-files=no > "$archive_dir/tracked-status.txt"
git -C "$workshop_root" diff --binary > "$archive_dir/uncommitted.patch"
git -C "$workshop_root" count-objects -vH > "$archive_dir/object-summary.txt"

mv "$git_dir" "$archive_dir/git-dir"

if [ -e "$git_dir" ]; then
  printf 'error: Git directory still exists after move\n' >&2
  exit 1
fi

printf '\nArchived successfully.\n'
printf 'The workshop root is no longer a Git repository.\n'
printf 'Recovery metadata and the complete original Git directory are at:\n%s\n' "$archive_dir"
