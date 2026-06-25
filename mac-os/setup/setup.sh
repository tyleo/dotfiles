#!/usr/bin/env bash
# Full new-Mac setup. Runs each step below in order; every step is also safe to
# run on its own (e.g. `internal/vscode.sh` to just refresh extensions). Steps are
# ABC-ordered; the only cross-step dependency (mas.sh needs brew from homebrew.sh)
# is already satisfied since "homebrew" sorts before "mas".
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

steps=(
  apps.sh
  cargo.sh
  cli.sh
  homebrew.sh
  manual-apps.sh
  mas.sh
  node.sh
  vscode.sh
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/internal/$step"
done

echo "Done. Restart your terminal."
