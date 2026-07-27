#!/bin/sh

# Read-only workstation audit. It deliberately avoids identity values, key
# contents, tokens, repository contents, and network secrets.

set -u

section() {
  printf '\n[%s]\n' "$1"
}

present() {
  if command -v "$1" >/dev/null 2>&1; then
    printf '%-14s %s\n' "$1" "$(command -v "$1")"
  else
    printf '%-14s %s\n' "$1" "not found"
  fi
}

section system
printf 'ComputerName: %s\n' "$(scutil --get ComputerName 2>/dev/null || printf unknown)"
printf 'LocalHostName: %s\n' "$(scutil --get LocalHostName 2>/dev/null || printf unknown)"
sw_vers
printf 'architecture: %s\n' "$(uname -m)"
memory_bytes="$(sysctl -n hw.memsize 2>/dev/null || printf unknown)"
printf 'memory-bytes: %s\n' "$memory_bytes"

section tools
for tool in git ssh ssh-keygen rsync brew code docker python3 rustc cargo R; do
  present "$tool"
done

section versions
git --version 2>/dev/null || true
ssh -V 2>&1 || true
python3 --version 2>/dev/null || true
brew --version 2>/dev/null | sed -n '1,2p' || true

section git
if git config --global --get user.name >/dev/null 2>&1; then
  printf 'user.name: configured\n'
else
  printf 'user.name: not configured\n'
fi
if git config --global --get user.email >/dev/null 2>&1; then
  printf 'user.email: configured\n'
else
  printf 'user.email: not configured\n'
fi
printf 'default branch: %s\n' \
  "$(git config --global --get init.defaultBranch 2>/dev/null || printf not-configured)"
printf 'pull mode: %s\n' \
  "$(git config --global --get pull.ff 2>/dev/null || printf not-configured)"
printf 'credential helper: %s\n' \
  "$(git config --global --get credential.helper 2>/dev/null || printf not-configured)"

section ssh
if [ -d "$HOME/.ssh" ]; then
  # Filenames and permissions only; no key material or comments.
  find "$HOME/.ssh" -maxdepth 1 -type f \
    -exec stat -f '%N %Sp' {} \; 2>/dev/null |
    sed "s|$HOME|~|" |
    sort
else
  printf '~/.ssh: absent\n'
fi
launchctl print-disabled system 2>/dev/null | sed -n '/ssh/p' || true

section storage
df -h / | sed -n '1p;$p'
diskutil list external physical 2>/dev/null || true

section time-machine
tmutil destinationinfo 2>&1 || true
tmutil latestbackup 2>&1 || true

section workshop
if [ -d "$HOME/workshop" ]; then
  printf 'root: ~/workshop\n'
  printf 'top-level entries: '
  find "$HOME/workshop" -mindepth 1 -maxdepth 1 -print 2>/dev/null |
    wc -l |
    tr -d ' '
  printf '\n'
  printf 'size: '
  du -sh "$HOME/workshop" 2>/dev/null | awk '{print $1}'
else
  printf 'root: absent\n'
fi
