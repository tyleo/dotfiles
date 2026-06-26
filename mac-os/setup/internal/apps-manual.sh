#!/usr/bin/env bash
# Apps we do not auto-install: downloads behind a bot challenge (e.g. Cloudflare)
# that we will not work around, plus paid or ambiguous apps not worth scripting.
# Just prints a reminder to install each by hand if it is missing. Apps with a
# clean direct download live in apps-dmg.sh / apps-zip.sh.
#
# Each row is a "<name>" line followed by its "<url>" line. manual_apps holds those
# pairs and install_rows handles each. Entries are ABC-ordered by name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

manual_apps=(
  "Araxis Merge"
  "https://www.araxis.com/merge/"

  "Aseprite"
  "https://www.aseprite.org/"

  "Claude"
  "https://claude.ai/download"

  "Codex"
  "https://chatgpt.com/codex"

  "CrossOver"
  "https://www.codeweavers.com/crossover/download"
)

install_rows 2 warn_manual_install "${manual_apps[@]}"
