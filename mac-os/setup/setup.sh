#!/usr/bin/env bash

# Full new-Mac setup. Runs each step below in order. Every step is also safe
# to run on its own.
#
# Ordering:
#   1. homebrew.sh runs first to install Homebrew plus every Brewfile package.
#   2. default-apps.sh binds file types to apps, so it follows the app
#      installers.
#   3. zsh-plugins.sh clones the Oh My Zsh custom plugins, so it follows
#      cli.sh's Oh My Zsh install.
#   4. dotfiles.sh runs after the tool installers to lay the managed rc files
#      over whatever they appended.
#   5. system-setup.sh applies macOS settings via the .zshrc setters. It reads
#      the repo copy, so it does not depend on dotfiles.sh.
#   6. bin-links.sh runs last to link app CLIs into ~/.local/bin.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

steps=(
  homebrew.sh
  apps-app-store.sh
  apps-dmg.sh
  apps-manual.sh
  apps-steam.sh
  apps-zip.sh
  cargo.sh
  cli.sh
  node.sh
  pkg.sh
  vscode.sh
  default-apps.sh
  zsh-plugins.sh
  dotfiles.sh
  codex.sh
  system-setup.sh
  bin-links.sh
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/internal/$step"
done

echo "Done. Restart your terminal."
