#!/usr/bin/env bash
# Install Mac App Store apps with mas. Requires being signed in to the App Store
# first (mas can no longer sign in from the CLI), and each app must already be in
# your purchase history. mas itself is installed by homebrew.sh (brew "mas").
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew
if ! command -v mas &>/dev/null; then
  echo "ERROR: 'mas' not found; it is installed by homebrew.sh (brew \"mas\")." >&2
  exit 1
fi

# Amazon Kindle (id 302584613). The current, Apple Silicon-native Kindle that
# self-updates; the legacy direct-download Kindle is x86-only with no updater.
if mas list | grep -q '^302584613'; then
  echo "Amazon Kindle already installed."
elif ! mas install 302584613; then
  echo "Could not install Amazon Kindle. Sign in to the App Store, then run: mas install 302584613" >&2
fi
