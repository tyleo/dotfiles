#!/usr/bin/env bash
# Full new-Mac setup. Runs each step below in order; every step is also safe to run
# on its own (e.g. `internal/vscode.sh` to just refresh extensions), because any step
# that needs Homebrew or the Xcode Command Line Tools it installs (git, a C compiler,
# a linker) calls ensure_brew to set that foundation up on demand. Run order is
# therefore not load-bearing.
#
# homebrew.sh is still listed first, to install that foundation plus every Brewfile
# package once up front - cargo.sh (compiles crates) and cli.sh (Oh My Zsh clones with
# git) build on it. The remaining steps are independent and ABC-ordered.
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
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/internal/$step"
done

echo "Done. Restart your terminal."
