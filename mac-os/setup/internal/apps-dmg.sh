#!/usr/bin/env bash
# Install GUI apps shipped as a .dmg, straight into /Applications so they own their
# own updates (no Homebrew). Zip-based apps live in apps-zip.sh; apps that need a
# pkg installer or do not self-update live in the Brewfile; apps we do not auto-
# install at all (bot-gated, paid, ambiguous) live in apps-manual.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. dmg_apps holds those
# pairs and install_pairs installs each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

dmg_apps=(
  # ChatGPT. The "_latest" alias always serves the current build; self-updates.
  "ChatGPT"
  "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"

  # Discord. Non-versioned URL redirects to the current build; self-updates.
  "Discord"
  "https://discord.com/api/download?platform=osx"

  # Firefox. "latest-ssl" URL always redirects to the current dmg; self-updates.
  "Firefox"
  "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"

  # Ghostty. No "latest" URL exists, so this is pinned to a version: bump it when the
  # download 404s. Self-updates after first install, so the URL only matters when
  # bootstrapping a Mac.
  "Ghostty"
  "https://release.files.ghostty.org/1.3.1/Ghostty.dmg"

  # Google Chrome. Non-versioned universal stable build; self-updates (Keystone).
  "Google Chrome"
  "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"

  # Obsidian. No "latest" URL exists, so this is pinned to a version: bump it when the
  # download 404s. Self-updates after first install, so the pin only matters when
  # bootstrapping a Mac.
  "Obsidian"
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/Obsidian-1.12.7.dmg"

  # Rectangle Pro. Paid window manager; Sparkle self-updates. No "latest" URL, so this
  # is pinned: bump it when the download 404s.
  "Rectangle Pro"
  "https://rectangleapp.com/pro/downloads/Rectangle%20Pro%203.80.dmg"

  # Signal. No "latest" URL exists, so this is pinned to a version: bump it when the
  # download 404s (check updates.signal.org/desktop/latest-mac.yml). Self-updates
  # after first install, so the pin only matters when bootstrapping.
  "Signal"
  "https://updates.signal.org/desktop/signal-desktop-mac-universal-8.16.0.dmg"

  # Spotify. No version in the URL, so it never goes stale; self-updates. This is the
  # Apple Silicon build; on Intel use https://download.scdn.co/Spotify.dmg.
  "Spotify"
  "https://download.scdn.co/SpotifyARM64.dmg"

  # Steam. Valve CDN "latest" installer, no version in URL; self-updates. The dmg is a
  # small bootstrapper that pulls the full client on first launch.
  "Steam"
  "https://cdn.cloudflare.steamstatic.com/client/installer/steam.dmg"

  # Unity Hub. The "prod" alias always serves the current build; self-updates. Apple
  # Silicon build; on Intel use .../hub/prod/UnityHubSetup-x64.dmg.
  "Unity Hub"
  "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-arm64.dmg"

  # VIA. Electron wrapper around usevia.app, so it always loads the latest VIA. No
  # "latest" URL, so this is pinned: bump it when the download 404s.
  "VIA"
  "https://github.com/the-via/releases/releases/download/v3.0.0/via-3.0.0-mac.dmg"

  # VLC. Native arm64 dmg; built-in updater self-updates after first install. The
  # "last" path is an index, so the filename is pinned: bump it when it 404s.
  "VLC"
  "https://get.videolan.org/vlc/last/macosx/vlc-3.0.23-arm64.dmg"
)

install_pairs install_app_dmg "${dmg_apps[@]}"
