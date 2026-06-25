#!/usr/bin/env bash
# Install GUI apps that have a clean direct download, straight into /Applications
# so they own their own updates (no Homebrew). Apps whose download sits behind a
# bot challenge live in manual-apps.sh instead.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# ChatGPT. The "_latest" alias always serves the current build; self-updates.
install_app_dmg "ChatGPT" \
  "https://persistent.oaistatic.com/sidekick/public/ChatGPT_Desktop_public_latest.dmg"

# ForkLift. "ForkLift4" is a stable alias for the current v4 release; self-updates.
install_app_zip "ForkLift" \
  "https://download.binarynights.com/ForkLift/ForkLift4.zip"

# Ghostty. No "latest" URL exists, so this is pinned to a version: bump it when
# the download 404s. Ghostty self-updates after the first install, so this URL
# only matters when bootstrapping a Mac.
install_app_dmg "Ghostty" \
  "https://release.files.ghostty.org/1.3.1/Ghostty.dmg"

# Spotify. No version in the URL, so it never goes stale; self-updates. This is
# the Apple Silicon build; on Intel use https://download.scdn.co/Spotify.dmg.
install_app_dmg "Spotify" \
  "https://download.scdn.co/SpotifyARM64.dmg"
