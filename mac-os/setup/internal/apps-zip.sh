#!/usr/bin/env bash
# Install GUI apps shipped as a .zip, straight into /Applications so they own
# their own updates (no Homebrew). Dmg-based apps live in apps-dmg.sh; apps that
# need a pkg installer or do not self-update live in the Brewfile; apps we do
# not auto-install at all (bot-gated, paid, ambiguous) live in apps-manual.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. zip_apps holds those
# pairs and install_rows installs each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

zip_apps=(
  "1Password"
  "https://downloads.1password.com/mac/1Password-latest-aarch64.zip"

  "Airfoil"
  "https://cdn.rogueamoeba.com/airfoil/mac/download/Airfoil.zip"

  "Airfoil Satellite"
  "https://rogueamoeba.com/airfoil/satellite/mac/download/AirfoilSatelliteMac.zip"

  "ForkLift"
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"
)

install_rows 2 install_app_zip "${zip_apps[@]}"
