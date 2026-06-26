#!/usr/bin/env bash

# Install `nvm` + an LTS Node.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

ensure_nvm

# Make sure a Node is installed and on PATH.
if ! command -v node &>/dev/null; then
  nvm install --lts
fi
