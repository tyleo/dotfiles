#!/usr/bin/env bash
# Install GUI apps that have a clean direct download, straight into /Applications
# so they own their own updates (no Homebrew). Apps that need a pkg installer or
# do not self-update live in the Brewfile; apps we do not auto-install at all
# (bot-gated, paid, ambiguous) live in manual-apps.sh. Entries are ABC-ordered.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# 1Password 8. Stable "latest" aarch64 URL; self-updates. Installs without
# payment, but needs a paid account to actually use.
install_app_zip "1Password" \
  "https://downloads.1password.com/mac/1Password-latest-aarch64.zip"

# Airfoil. Paid - enter a license after install; runs as a demo until then.
# Sparkle self-updates. The zip wraps everything in an "Airfoil/" folder, so the
# install_app_zip helper would mis-place it; extract and move Airfoil.app out.
if [ ! -d "/Applications/Airfoil.app" ]; then
  echo "Downloading Airfoil..."
  tmp="$(mktemp -d)"
  curl -fsSL "https://cdn.rogueamoeba.com/airfoil/mac/download/Airfoil.zip" -o "$tmp/Airfoil.zip"
  ditto -x -k "$tmp/Airfoil.zip" "$tmp"
  cp -R "$tmp/Airfoil/Airfoil.app" /Applications/
  rm -rf "$tmp"
fi

# Airfoil Satellite. Free companion receiver; Sparkle self-updates. Stable URL,
# bundle "Airfoil Satellite.app" sits at the zip root.
install_app_zip "Airfoil Satellite" \
  "https://rogueamoeba.com/airfoil/satellite/mac/download/AirfoilSatelliteMac.zip"

# ChatGPT. The "_latest" alias always serves the current build; self-updates.
install_app_dmg "ChatGPT" \
  "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"

# Discord. Non-versioned URL redirects to the current build; self-updates.
install_app_dmg "Discord" \
  "https://discord.com/api/download?platform=osx"

# Firefox. "latest-ssl" URL always redirects to the current dmg; self-updates.
install_app_dmg "Firefox" \
  "https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"

# ForkLift. "ForkLift4" is a stable alias for the current v4 release; self-updates.
install_app_zip "ForkLift" \
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"

# Ghostty. No "latest" URL exists, so this is pinned to a version: bump it when
# the download 404s. Ghostty self-updates after the first install, so this URL
# only matters when bootstrapping a Mac.
install_app_dmg "Ghostty" \
  "https://release.files.ghostty.org/1.3.1/Ghostty.dmg"

# Google Chrome. Non-versioned universal stable build; self-updates (Keystone).
install_app_dmg "Google Chrome" \
  "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg"

# Obsidian. No "latest" URL exists, so this is pinned to a version: bump it when
# the download 404s. Self-updates after first install, so the pin only matters
# when bootstrapping a Mac.
install_app_dmg "Obsidian" \
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/Obsidian-1.12.7.dmg"

# Rectangle Pro. Paid window manager; Sparkle self-updates. No "latest" URL, so
# this is pinned: bump it when the download 404s.
install_app_dmg "Rectangle Pro" \
  "https://rectangleapp.com/pro/downloads/Rectangle%20Pro%203.80.dmg"

# Signal. No "latest" URL exists, so this is pinned to a version: bump it when the
# download 404s (check updates.signal.org/desktop/latest-mac.yml). Self-updates
# after first install, so the pin only matters when bootstrapping.
install_app_dmg "Signal" \
  "https://updates.signal.org/desktop/signal-desktop-mac-universal-8.16.0.dmg"

# Spotify. No version in the URL, so it never goes stale; self-updates. This is
# the Apple Silicon build; on Intel use https://download.scdn.co/Spotify.dmg.
install_app_dmg "Spotify" \
  "https://download.scdn.co/SpotifyARM64.dmg"

# Steam. Valve CDN "latest" installer, no version in URL; self-updates. The dmg
# is a small bootstrapper that pulls the full client on first launch.
install_app_dmg "Steam" \
  "https://cdn.cloudflare.steamstatic.com/client/installer/steam.dmg"

# Unity Hub. The "prod" alias always serves the current build; self-updates.
# Apple Silicon build; on Intel use .../hub/prod/UnityHubSetup-x64.dmg.
install_app_dmg "Unity Hub" \
  "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-arm64.dmg"

# VIA. Electron wrapper around usevia.app, so it always loads the latest VIA. No
# "latest" URL, so this is pinned: bump it when the download 404s.
install_app_dmg "VIA" \
  "https://github.com/the-via/releases/releases/download/v3.0.0/via-3.0.0-mac.dmg"

# VLC. Native arm64 dmg; built-in updater self-updates after first install. The
# "last" path is an index, so the filename is pinned: bump it when it 404s.
install_app_dmg "VLC" \
  "https://get.videolan.org/vlc/last/macosx/vlc-3.0.23-arm64.dmg"
