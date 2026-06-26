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

  "ForkLift"
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"
)

install_rows 2 install_app_zip "${items[@]}"
