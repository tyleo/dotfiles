#!/usr/bin/env bash
# Install Homebrew (if missing) and everything in the Brewfile (CLIs, casks,
# fonts).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

ensure_brew
brew bundle --file="$DIR/Brewfile"
