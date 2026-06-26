#!/usr/bin/env bash

# Apps we buy and run through Steam. Steam keeps them in its own library and
# updates them itself, and the client will not install them without a signed-in
# session, so this only reminds us to grab each one from the Steam app if it is
# missing.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "Aseprite"
  431730

  "Resprite"
  3146020
)

install_rows 2 warn_steam_install "${items[@]}"
