#!/bin/sh

# Read-only development environment inventory. Reports executable locations and
# versions without reading credentials, shell history, or project contents.

set -u

# Prefer the native Apple-silicon Homebrew when an older Intel installation
# also exists in /usr/local.
if [ "$(uname -m)" = arm64 ] && [ -x /opt/homebrew/bin/brew ]; then
  PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export PATH
fi

machine="$(scutil --get ComputerName 2>/dev/null || hostname)"

printf '# machine\t%s\n' "$machine"
printf '# generated\t%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf '# shell\t%s\n' "${SHELL:-unknown}"
printf 'tool\tlocation\tversion\n'

first_line() {
  "$@" 2>&1 | sed -n '1p' | tr '\t' ' '
}

report() {
  tool="$1"
  shift

  location="$(command -v "$tool" 2>/dev/null || true)"
  if [ -z "$location" ]; then
    printf '%s\t-\tnot-installed\n' "$tool"
    return
  fi

  version="$(first_line "$@" || true)"
  [ -n "$version" ] || version='installed-version-unknown'
  printf '%s\t%s\t%s\n' "$tool" "$location" "$version"
}

report brew brew --version
report git git --version
report gh gh --version
report ssh ssh -V
report rsync rsync --version

report clang clang --version
report make make --version
report cmake cmake --version
report ninja ninja --version
report pkg-config pkg-config --version

report python3 python3 --version
report uv uv --version
report pyenv pyenv --version
report mise mise --version
report conda conda --version
report pipx pipx --version
report poetry poetry --version

report rustup rustup --version
report rustc rustc --version
report cargo cargo --version

report R R --version
report quarto quarto --version

report docker docker --version
report docker-compose docker-compose --version
report colima colima version

report latexmk latexmk --version
report pdflatex pdflatex --version
report tectonic tectonic --version

report node node --version
report corepack corepack --version

printf '\n[apple-toolchain]\n'
xcode-select -p 2>&1 || true
first_line xcrun --show-sdk-version || true

printf '\n[homebrew-prefix]\n'
brew --prefix 2>/dev/null || true

printf '\n[git-policy]\n'
printf 'default-branch\t%s\n' \
  "$(git config --global --get init.defaultBranch 2>/dev/null || printf not-configured)"
printf 'pull-ff\t%s\n' \
  "$(git config --global --get pull.ff 2>/dev/null || printf not-configured)"
printf 'autocrlf\t%s\n' \
  "$(git config --global --get core.autocrlf 2>/dev/null || printf not-configured)"

printf '\n[docker-engine]\n'
if command -v docker >/dev/null 2>&1; then
  docker info --format 'server={{.ServerVersion}} os={{.OperatingSystem}} arch={{.Architecture}}' 2>&1 || true
else
  printf 'not-installed\n'
fi
