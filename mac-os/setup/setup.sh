#!/usr/bin/env bash
# Full new-Mac setup. Runs each step below in order; every step is also safe to
# run on its own (e.g. `internal/vscode.sh` to just refresh extensions), because
# any step that needs Homebrew or the Xcode Command Line Tools it installs (git,
# a C compiler, a linker) calls ensure_brew to set that foundation up on demand.
#
# homebrew.sh is listed first, to install that foundation plus every Brewfile
# package once up front - cargo.sh (compiles crates) and cli.sh (Oh My Zsh
# clones with git) build on it. dotfiles.sh is listed last, so it lays the
# managed shell rc files (~/.zshrc, ~/.zprofile, ~/.zshenv) down over whatever
# the tool installers (nvm, rustup, brew) appended to them - the repo's copies
# win, no duplicate snippets. The steps in between are independent and
# ABC-ordered.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

steps=(
  homebrew.sh
  apps-app-store.sh
  apps-dmg.sh
  apps-manual.sh
  apps-zip.sh
  cargo.sh
  cli.sh
  node.sh
  pkg.sh
  vscode.sh
  dotfiles.sh
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/internal/$step"
done

echo "Done. Restart your terminal."
