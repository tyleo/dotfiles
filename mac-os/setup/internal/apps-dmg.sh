#!/usr/bin/env bash
# Install GUI apps shipped as a .dmg, straight into /Applications so they own their
# own updates (no Homebrew). Zip-based apps live in apps-zip.sh; apps that need a
# pkg installer or do not self-update live in the Brewfile; apps we do not auto-
# install at all (bot-gated, paid, ambiguous) live in apps-manual.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. dmg_apps holds those
# pairs and install_rows installs each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

dmg_apps=(
  "ChatGPT"
  "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"

  "Discord"
  "https://discord.com/api/download?platform=osx"

  "Firefox"
  "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"

  "Ghostty"
  "https://release.files.ghostty.org/1.3.1/Ghostty.dmg"

  "Google Chrome"
  "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"

  "Obsidian"
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/Obsidian-1.12.7.dmg"

  "Rectangle Pro"
  "https://rectangleapp.com/pro/downloads/Rectangle%20Pro%203.80.dmg"

  "Signal"
  "https://updates.signal.org/desktop/signal-desktop-mac-universal-8.16.0.dmg"

  "Spotify"
  "https://download.scdn.co/SpotifyARM64.dmg"

  "Steam"
  "https://cdn.cloudflare.steamstatic.com/client/installer/steam.dmg"

  "Unity Hub"
  "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-arm64.dmg"

  "VIA"
  "https://github.com/the-via/releases/releases/download/v3.0.0/via-3.0.0-mac.dmg"

  "VLC"
  "https://get.videolan.org/vlc/last/macosx/vlc-3.0.23-arm64.dmg"
)

install_rows 2 install_app_dmg "${dmg_apps[@]}"
