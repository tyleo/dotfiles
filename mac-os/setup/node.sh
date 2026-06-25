#!/usr/bin/env bash
# Install nvm + an LTS Node, then enable Corepack (the yarn/pnpm shim manager
# that ships with Node).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

ensure_nvm

# Corepack ships with Node, so make sure a Node is installed and on PATH first.
# nvm install --lts also activates the version it installs.
if ! command -v node &>/dev/null; then
  nvm install --lts
fi

# Set up the Corepack shims (yarn, pnpm).
corepack enable
