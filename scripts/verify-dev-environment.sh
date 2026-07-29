#!/bin/sh

# Verify commands expected on both workstations. This script is read-only.

set -u

PATH="$HOME/.local/bin:$PATH"
export PATH

# Prefer the native Apple-silicon Homebrew when an older Intel installation
# also exists in /usr/local.
if [ "$(uname -m)" = arm64 ] && [ -x /opt/homebrew/bin/brew ]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export PATH
fi

required='brew git gh ssh rsync clang make cmake ninja pkg-config python3 uv rustup rustc cargo R latexmk fish jq'
missing=0

printf 'tool\tlocation\tversion\n'
for tool in $required; do
  location="$(command -v "$tool" 2>/dev/null || true)"
  if [ -z "$location" ]; then
    printf '%s\t-\tMISSING\n' "$tool"
    missing=$((missing + 1))
    continue
  fi

  case "$tool" in
    ssh) version="$("$tool" -V 2>&1 | sed -n '1p')" ;;
    R) version="$("$tool" --version 2>&1 | sed -n '1p')" ;;
    latexmk) version="$("$tool" --version 2>&1 | sed -n '1p')" ;;
    *) version="$("$tool" --version 2>&1 | sed -n '1p')" ;;
  esac
  printf '%s\t%s\t%s\n' "$tool" "$location" "$version"
done

printf '\n'
if [ "$missing" -eq 0 ]; then
  printf 'PASS: shared development baseline is available.\n'
  exit 0
fi

printf 'FAIL: %s required command(s) are missing.\n' "$missing" >&2
printf 'Run scripts/bootstrap-dev-environment.sh to inspect Brewfile status.\n' >&2
exit 1
