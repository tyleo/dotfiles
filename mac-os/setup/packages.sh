#!/usr/bin/env bash
# Install everything in the Brewfile (CLIs, casks, fonts).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew
brew bundle --file="$DIR/Brewfile"
