#!/usr/bin/env bash
# Install Homebrew if it isn't already present.
set -euo pipefail

if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
