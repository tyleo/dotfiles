#!/usr/bin/env bash

# Apply macOS system settings by calling the setter functions defined in the
# managed .zshrc, so the defaults writes live in one place. Sources the repo
# copy rather than ~/.zshrc, so this step does not depend on dotfiles.sh.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$(cd "$DIR/../../usr" && pwd)/.zshrc"

zsh -c '
  source "$1" >/dev/null 2>&1 || true
  rc=0
  set_dock_animation_speed || rc=1
  set_key_repeat || rc=1
  set_file_viewer_to_forklift || rc=1
  set_finder_show_hidden_files || rc=1
  exit $rc
' _ "$ZSHRC"
