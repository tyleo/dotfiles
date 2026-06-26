#!/usr/bin/env bash
# Install Mac App Store apps with mas. Requires being signed in to the App Store
# first (mas can no longer sign in from the CLI), and each app must already be in
# your purchase history. mas itself is installed by this script.
#
# Each row is a "<name>" line followed by its <app-store-id> line. app_store_apps
# holds those pairs and install_pairs installs each. Entries are ABC-ordered by name.
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
  # Amazon Kindle. Apple Silicon-native build that self-updates; the legacy direct-
  # download Kindle is x86-only with no updater.
  "Amazon Kindle"
  302584613

  # Combustion Inc. Companion app for Combustion thermometers (iPad app on Apple
  # Silicon). "Combustion" is ambiguous - this is the cooking one, not Autodesk.
  "Combustion Inc."
  1658858290

  # GarageBand. Apple's free DAW, Mac App Store only.
  "GarageBand"
  682658836

  # Kirsch Automation. Controls motorized window coverings (iPad app on Apple Silicon).
  "Kirsch Automation"
  1469943618

  # Microsoft Excel. Self-updates via the App Store; needs Microsoft 365 to edit.
  "Microsoft Excel"
  462058435

  # Microsoft OneNote. Fully free, no subscription needed.
  "Microsoft OneNote"
  784801555

  # Microsoft PowerPoint. Self-updates via the App Store; needs Microsoft 365 to edit.
  "Microsoft PowerPoint"
  462062816

  # Microsoft Word. Self-updates via the App Store; needs Microsoft 365 to edit.
  "Microsoft Word"
  462054704

  # Pixquare. Pixel art studio (iPad app on Apple Silicon). Free, has in-app purchases.
  "Pixquare"
  1659428179

  # Resprite. Pixel art studio (iPad app on Apple Silicon). Free, has in-app purchases.
  "Resprite"
  1662335989

  # TestFlight. Apple's beta installer, Mac App Store only.
  "TestFlight"
  899247664

  # UniFi. Ubiquiti network manager (iPad app on Apple Silicon).
  "UniFi"
  1057750338

  # Voxel Max. Paid ($9.99) voxel editor (iPad app on Apple Silicon); must be bought
  # in the App Store before mas can install it.
  "Voxel Max"
  1442352186

  # Xcode. Apple's IDE; large (~10GB+) download.
  "Xcode"
  497799835
)

install_pairs mas_install "${app_store_apps[@]}"
