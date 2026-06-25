#!/usr/bin/env bash
# Install nvm (Node Version Manager). Run `nvm install --lts` afterwards to get
# a Node version.
set -euo pipefail

if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

npm corepack
