#!/usr/bin/env bash

# Install GUI apps shipped as a `.dmg`, straight into `/Applications` so they
# own their own updates.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "Discord"
  "https://discord.com/api/download?platform=osx"

  "Firefox"
  "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"

  "Ghostty"
  "sparkle https://release.files.ghostty.org/appcast.xml"

  "Google Chrome"
  "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"

  "Luna Display"
  "https://downloads.astropad.com/luna/mac/latest"

  "Luna Secondary"
  "https://downloads.astropad.com/luna-secondary/mac/latest"

  "Notion"
  "https://www.notion.com/desktop/mac-apple-silicon/download"

  "Obsidian"
  "github obsidianmd/obsidian-releases ^Obsidian-[0-9.]+\.dmg$"

  "Rectangle Pro"
  "sparkle https://rectangleapp.com/pro/downloads/updates.xml"

  "Spotify"
  "https://download.scdn.co/SpotifyARM64.dmg"

  "Unity Hub"
  "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-arm64.dmg"

  "VLC"
  "sparkle https://update.videolan.org/vlc/sparkle/vlc-arm64.xml"
)

install_rows 2 install_app_dmg "${items[@]}"
