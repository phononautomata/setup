#!/bin/sh

# Install uv from Astral's prebuilt standalone release. Preview by default.
# This avoids unsupported Homebrew source builds on older macOS releases.

set -eu

version='0.11.32'
installer_url="https://astral.sh/uv/$version/install.sh"
mode=preview

case "${1:-}" in
  '') ;;
  --apply) mode=apply ;;
  -h|--help)
    printf 'Usage: %s [--apply]\n' "$0"
    printf '  no flag  display the pinned installer and current state\n'
    printf '  --apply  download and run Astral uv %s installer\n' "$version"
    exit 0
    ;;
  *)
    printf 'Unknown argument: %s\n' "$1" >&2
    exit 2
    ;;
esac

printf 'mode:      %s\n' "$mode"
printf 'version:   %s\n' "$version"
printf 'installer: %s\n' "$installer_url"

if command -v uv >/dev/null 2>&1; then
  printf 'current:   %s\n' "$(uv --version)"
  printf '\nuv is already available; no installation is needed.\n'
  exit 0
fi

printf 'current:   not-installed\n'
if [ "$mode" = preview ]; then
  printf '\nNo changes were made. Install with: %s --apply\n' "$0"
  exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/setup-uv.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM
installer="$tmp_dir/install.sh"

curl --fail --location --silent --show-error "$installer_url" \
  --output "$installer"

# Keep shell configuration under the user's control. ~/.local/bin is already
# part of the documented workstation path.
UV_INSTALL_DIR="$HOME/.local/bin" UV_NO_MODIFY_PATH=1 sh "$installer"

if command -v fish >/dev/null 2>&1; then
  fish -c "fish_add_path '$HOME/.local/bin'"
fi

printf '\nInstalled: %s\n' "$HOME/.local/bin/uv"
printf 'The user-local executable directory is configured for fish.\n'
