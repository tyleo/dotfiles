#!/usr/bin/env bash

# Install Mac App Store apps with `mas`. Requires being signed in to the App
# Store first, and each app must already be in your purchase history. `mas`
# itself is installed by this script.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew

brew install mas

if ! command -v mas &>/dev/null; then
  echo "ERROR: \`mas\` could not be installed via Homebrew." >&2
  exit 1
fi

items=(
  "1Password for Safari"
  1569813296

  "Amazon Kindle"
  302584613

  "Combustion Inc."
  1658858290

  "GarageBand"
  682658836

  "Kirsch Automation"
  1469943618

  "Pixquare"
  1659428179

  "TestFlight"
  899247664

  "UniFi"
  1057750338

  "Voxel Max"
  1442352186

  "WiFiman"
  1385561119

  "Xcode"
  497799835
)

install_rows 2 mas_install "${items[@]}"
