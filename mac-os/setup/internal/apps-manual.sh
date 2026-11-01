#!/usr/bin/env bash

# Apps we do not auto-install. Just prints a reminder to install each by hand if
# it is missing. The list covers:
# 1. downloads behind a bot challenge that we will not work around
# 2. paid or ambiguous apps not worth scripting
# 3. iPhone and iPad App Store apps because `mas` cannot install them

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "Claude"
  "https://claude.com/download"

  "Combustion"
  "https://apps.apple.com/us/app/combustion-inc/id1658858290"

  "Kirsch"
  "https://apps.apple.com/us/app/kirsch-automation/id1469943618"

  # Suite pkg installs no "Microsoft 365.app", so Word marks it installed
  "Microsoft Word"
  "https://go.microsoft.com/fwlink/?linkid=525133"

  "Pixquare"
  "https://apps.apple.com/us/app/pixquare-pixel-art-studio/id1659428179"

  # Download page shows Meta's SDK license first
  "RenderDoc Meta Fork"
  "https://developers.meta.com/vr/downloads/package/renderdoc-meta-fork-for-mac-installer/"

  "UniFi"
  "https://apps.apple.com/us/app/unifi/id1057750338"
)

install_rows 2 warn_manual_install "${items[@]}"
