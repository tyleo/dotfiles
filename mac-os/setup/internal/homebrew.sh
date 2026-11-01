#!/usr/bin/env bash

# Install everything in the `Brewfile`. Homebrew itself is installed on demand
# by `ensure_brew`, so this step does not bootstrap it.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew

# Non-official taps must be trusted for brew to load their formulae when
# HOMEBREW_REQUIRE_TAP_TRUST is set. There is no Brewfile entry for this.
brew trust --tap rjyo/moshi

brew bundle --file="$DIR/Brewfile"
