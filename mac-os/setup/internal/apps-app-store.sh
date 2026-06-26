#!/usr/bin/env bash
# Install Mac App Store apps with mas. Requires being signed in to the App Store
# first (mas can no longer sign in from the CLI), and each app must already be in
# your purchase history. mas itself is installed by this script.
#
# Each row is a "<name>" line followed by its <app-store-id> line. app_store_apps
# holds those pairs and install_rows installs each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew
# Mac App Store command-line interface
brew install mas
if ! command -v mas &>/dev/null; then
  echo "ERROR: 'mas' could not be installed via Homebrew." >&2
  exit 1
fi

app_store_apps=(
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

  "Microsoft Excel"
  462058435

  "Microsoft OneNote"
  784801555

  "Microsoft PowerPoint"
  462062816

  "Microsoft Word"
  462054704

  "Pixquare"
  1659428179

  "Resprite"
  1662335989

  "TestFlight"
  899247664

  "UniFi"
  1057750338

  "Voxel Max"
  1442352186

  "Xcode"
  497799835
)

install_rows 2 mas_install "${app_store_apps[@]}"
