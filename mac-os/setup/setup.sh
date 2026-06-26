#!/usr/bin/env bash
# Full new-Mac setup. Runs each step below in order; every step is also safe to
# run on its own (e.g. `internal/vscode.sh` to just refresh extensions). Steps are
# ABC-ordered and independent: anything that needs Homebrew calls ensure_brew,
# which installs it on demand, so no run order between steps is required.
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
