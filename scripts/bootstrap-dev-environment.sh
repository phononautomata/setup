#!/bin/sh

# Check or install the shared development baseline declared in ../Brewfile.
# The default mode is read-only. Installation requires an explicit --apply.

set -eu

# Prefer the native Apple-silicon Homebrew when an older Intel installation
# also exists in /usr/local.
if [ "$(uname -m)" = arm64 ] && [ -x /opt/homebrew/bin/brew ]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export PATH
fi

# A baseline check should not trigger a full Homebrew update. Explicit package
# installation can still download the metadata and bottles it needs.
HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_AUTO_UPDATE

mode=check
case "${1:-}" in
  '')
    ;;
  --apply)
    mode=apply
    ;;
  -h|--help)
    printf 'Usage: %s [--apply]\n' "$0"
    printf '  no flag  check the Brewfile without installing anything\n'
    printf '  --apply  install missing Brewfile entries; does not upgrade everything\n'
    exit 0
    ;;
  *)
    printf 'Unknown argument: %s\n' "$1" >&2
    exit 2
    ;;
esac

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(dirname "$script_dir")"
brewfile="$repo_root/Brewfile"

if [ ! -f "$brewfile" ]; then
  printf 'Brewfile not found: %s\n' "$brewfile" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is required but was not found.\n' >&2
  printf 'Install it from https://brew.sh, then run this script again.\n' >&2
  exit 1
fi

printf 'mode:     %s\n' "$mode"
printf 'Brewfile: %s\n\n' "$brewfile"

if [ "$mode" = check ]; then
  if brew bundle check --verbose --no-upgrade --file="$brewfile"; then
    printf '\nShared development baseline is satisfied.\n'
  else
    printf '\nNo changes were made. Review the missing entries above.\n'
    printf 'Install them with: %s --apply\n' "$0"
    exit 1
  fi
else
  brew bundle --file="$brewfile" --no-upgrade
  printf '\nInstall phase complete. Verifying baseline...\n'
  "$script_dir/verify-dev-environment.sh"
fi
