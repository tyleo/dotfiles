#!/usr/bin/env bash
# Apps we do not auto-install: downloads behind a bot challenge (e.g. Cloudflare)
# that we will not work around, plus paid or ambiguous apps not worth scripting.
# Just prints a reminder to install each by hand if it is missing. Apps with a
# clean direct download live in apps-dmg.sh / apps-zip.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. manual_apps holds those
# pairs and install_pairs handles each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

manual_apps=(
  # Araxis Merge. Paid diff/merge tool; no "latest" URL and no self-updater, so not
  # worth scripting. 30-day trial on the site.
  "Araxis Merge"
  "https://www.araxis.com/merge/"

  # Aseprite. Paid pixel art editor with no free direct download (the page redirects
  # to checkout). Buy from the site, Steam, or itch.io.
  "Aseprite"
  "https://www.aseprite.org/"

  # Claude desktop app.
  "Claude"
  "https://claude.ai/download"

  # Codex app.
  "Codex"
  "https://chatgpt.com/codex"

  # CrossOver. Paid (14-day trial, then needs a license). The download is clean and
  # self-updates, so move it to apps-zip.sh if you want it auto-installed.
  "CrossOver"
  "https://www.codeweavers.com/crossover/download"
)

install_pairs warn_manual_install "${manual_apps[@]}"
