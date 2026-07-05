#!/usr/bin/env bash

# Install VS Code, then remind us to import the exported profile. The profile at
# `apps/visual-studio-code/tyleo.code-profile` carries the settings, keybindings,
# and extension set together, so importing it is the whole configuration in one
# step. VS Code has no CLI to import a `.code-profile` (the only `--profile` flag
# just opens an empty named profile), so the import itself is a manual click and
# this step only nudges - like `warn_manual_install` for apps we cannot fully
# automate.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

PROFILE="$(cd "$DIR/../../apps/visual-studio-code" && pwd)/tyleo.code-profile"
if [ ! -f "$PROFILE" ]; then
  echo "ERROR: VS Code profile missing: $PROFILE" >&2
  exit 1
fi

install_app_zip "Visual Studio Code" \
  "https://update.code.visualstudio.com/latest/darwin-universal/stable"

# Skip the nudge once a profile of this name exists. VS Code records imported
# profiles by name in this internal file; a format change here at worst prints
# the reminder again, which is harmless.
name="$(basename "$PROFILE" .code-profile)"
storage="$HOME/Library/Application Support/Code/User/globalStorage/storage.json"
if [ -f "$storage" ] && grep -Eq "\"name\"[[:space:]]*:[[:space:]]*\"$name\"" "$storage"; then
  exit 0
fi

echo "Manual step: the \"$name\" VS Code profile is not imported yet."
echo "  In VS Code: Profiles (gear, bottom-left) > Import Profile..., then select:"
echo "  $PROFILE"
