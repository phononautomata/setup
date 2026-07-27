#!/bin/sh

# Print public-key fingerprints and filenames only. A fingerprint can be safely
# compared between machines and does not reveal the private key.

set -u

found=0
for public_key in "$HOME"/.ssh/*.pub; do
  if [ ! -f "$public_key" ]; then
    continue
  fi
  found=1
  fingerprint="$(ssh-keygen -lf "$public_key" 2>/dev/null)" || {
    printf 'unreadable %s\n' "${public_key#"$HOME"/}"
    continue
  }
  # Drop the potentially identifying comment and retain bits, fingerprint,
  # algorithm, and local filename.
  printf '%s %s\n' \
    "$(printf '%s\n' "$fingerprint" | awk '{print $1, $2, $NF}')" \
    "${public_key#"$HOME"/}"
done

if [ "$found" -eq 0 ]; then
  printf 'No public SSH keys found under ~/.ssh\n'
fi
