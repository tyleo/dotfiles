#!/usr/bin/env bash

# Apps we do not auto-install: downloads behind a bot challenge that we will not
# work around, plus paid or ambiguous apps not worth scripting. Just prints a
# reminder to install each by hand if it is missing.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

items=(
  "Araxis Merge"
  "https://www.araxis.com/merge/"

  "Claude"
  "https://claude.ai/download"

  "Codex"
  "https://chatgpt.com/codex"

  "CrossOver"
  "https://www.codeweavers.com/crossover/download"

  "Microsoft 365"
  "https://go.microsoft.com/fwlink/?linkid=525133"
)

install_rows 2 warn_manual_install "${items[@]}"
