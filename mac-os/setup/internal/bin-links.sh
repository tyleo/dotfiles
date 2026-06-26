#!/usr/bin/env bash

# Symlink CLIs that ship inside installed `.app` bundles into `~/.local/bin`, so
# their short names run from anywhere without putting each app's private bin dir
# on PATH.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "blender"
  "/Applications/Blender.app/Contents/MacOS/Blender"

  "code"
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
)

install_rows 2 link_app_bin "${items[@]}"
