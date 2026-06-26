#!/usr/bin/env bash
# Install GUI apps shipped as a .zip, straight into /Applications so they own their
# own updates (no Homebrew). Dmg-based apps live in apps-dmg.sh; apps that need a
# pkg installer or do not self-update live in the Brewfile; apps we do not auto-
# install at all (bot-gated, paid, ambiguous) live in apps-manual.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. zip_apps holds those
# pairs and install_pairs installs each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

zip_apps=(
  # 1Password 8. Stable "latest" aarch64 URL; self-updates. Installs without payment,
  # but needs a paid account to actually use.
  "1Password"
  "https://downloads.1password.com/mac/1Password-latest-aarch64.zip"

  # Airfoil. Paid - enter a license after install; runs as a demo until then. Sparkle
  # self-updates. The zip wraps the bundle in an "Airfoil/" folder, which
  # install_app_zip finds one level down on its own.
  "Airfoil"
  "https://cdn.rogueamoeba.com/airfoil/mac/download/Airfoil.zip"

  # Airfoil Satellite. Free companion receiver; Sparkle self-updates. Stable URL,
  # bundle "Airfoil Satellite.app" sits at the zip root.
  "Airfoil Satellite"
  "https://rogueamoeba.com/airfoil/satellite/mac/download/AirfoilSatelliteMac.zip"

  # ForkLift. "ForkLift4" is a stable alias for the current v4 release; self-updates.
  "ForkLift"
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"
)

install_pairs install_app_zip "${zip_apps[@]}"
