#!/usr/bin/env bash
# Install Mac App Store apps with mas. Requires being signed in to the App Store
# first (mas can no longer sign in from the CLI), and each app must already be in
# your purchase history. mas itself is installed by this script. Entries are
# ABC-ordered.
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

# Amazon Kindle. Apple Silicon-native build that self-updates; the legacy direct-
# download Kindle is x86-only with no updater.
mas_install 302584613 "Amazon Kindle"
# Combustion Inc. Companion app for Combustion thermometers (iPad app on Apple
# Silicon). "Combustion" is ambiguous - this is the cooking one, not Autodesk.
mas_install 1658858290 "Combustion Inc."
# GarageBand. Apple's free DAW, Mac App Store only.
mas_install 682658836 "GarageBand"
# Kirsch Automation. Controls motorized window coverings (iPad app on Apple Silicon).
mas_install 1469943618 "Kirsch Automation"
# Microsoft Excel. Self-updates via the App Store; needs Microsoft 365 to edit.
mas_install 462058435 "Microsoft Excel"
# Microsoft OneNote. Fully free, no subscription needed.
mas_install 784801555 "Microsoft OneNote"
# Microsoft PowerPoint. Self-updates via the App Store; needs Microsoft 365 to edit.
mas_install 462062816 "Microsoft PowerPoint"
# Microsoft Word. Self-updates via the App Store; needs Microsoft 365 to edit.
mas_install 462054704 "Microsoft Word"
# Pixquare. Pixel art studio (iPad app on Apple Silicon). Free, has in-app purchases.
mas_install 1659428179 "Pixquare"
# Resprite. Pixel art studio (iPad app on Apple Silicon). Free, has in-app purchases.
mas_install 1662335989 "Resprite"
# TestFlight. Apple's beta installer, Mac App Store only.
mas_install 899247664 "TestFlight"
# UniFi. Ubiquiti network manager (iPad app on Apple Silicon).
mas_install 1057750338 "UniFi"
# Voxel Max. Paid ($9.99) voxel editor (iPad app on Apple Silicon); must be bought
# in the App Store before mas can install it.
mas_install 1442352186 "Voxel Max"
# Xcode. Apple's IDE; large (~10GB+) download.
mas_install 497799835 "Xcode"
