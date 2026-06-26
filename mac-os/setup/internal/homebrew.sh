#!/usr/bin/env bash
# Install everything in the Brewfile (CLIs, casks, fonts). Homebrew itself is
# installed on demand by ensure_brew, so this step does not bootstrap it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew
brew bundle --file="$DIR/Brewfile"
