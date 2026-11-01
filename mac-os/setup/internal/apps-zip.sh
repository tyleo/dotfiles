#!/usr/bin/env bash

# Install GUI apps shipped as a `.zip`, straight into `/Applications` so they
# own their own updates.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "1Password"
  "https://downloads.1password.com/mac/1Password-latest-aarch64.zip"

  "Airfoil"
  "https://cdn.rogueamoeba.com/airfoil/mac/download/Airfoil.zip"

  "Airfoil Satellite"
  "https://rogueamoeba.com/airfoil/satellite/mac/download/AirfoilSatelliteMac.zip"

  # The combined ChatGPT and Codex app
  "ChatGPT"
  "sparkle https://persistent.oaistatic.com/codex-app-prod/appcast.xml"

  # Runs as a trial until the CodeWeavers license is entered
  "CrossOver"
  "sparkle https://www.codeweavers.com/xml/versions/cxmac.xml"

  "ForkLift"
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"

  # Meta's only Mac download is the updater's app zip
  "Meta Quest Developer Hub"
  "electron https://www.oculus.com/electron-updates/mqdh/latest-mac.yml \.zip$"

  # Shipped as a zip because Signal has no arm64 dmg
  "Signal"
  "electron https://updates.signal.org/desktop/latest-mac.yml mac-arm64-.*\.zip$"
)

install_rows 2 install_app_zip "${items[@]}"
