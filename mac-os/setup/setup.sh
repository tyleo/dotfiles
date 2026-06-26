#!/usr/bin/env bash

# Full new-Mac setup. Runs each step below in order; every step is also safe to
# run on its own (e.g. `internal/vscode.sh` to just refresh extensions).
#
# `homebrew.sh` is listed first, to install that foundation plus every
# `Brewfile` package once up front. `dotfiles.sh` runs after the tool
# installers, so it lays the managed shell rc files down over whatever they
# appended to them. `bin-links.sh` runs last, linking app CLIs into
# `~/.local/bin` once those apps are in `/Applications`. `zsh-plugins.sh` clones
# the Oh My Zsh custom plugins, so it leans on `cli.sh`'s Oh My Zsh install.

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
  zsh-plugins.sh
  dotfiles.sh
  bin-links.sh
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/internal/$step"
done

echo "Done. Restart your terminal."
