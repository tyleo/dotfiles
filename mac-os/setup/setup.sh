#!/usr/bin/env bash
# Full new-Mac setup. Runs each step below in order; every step is also safe to
# run on its own (e.g. `./vscode.sh` to just refresh extensions).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

steps=(
  homebrew.sh
  packages.sh
  cargo.sh
  vscode.sh
  node.sh
)

for step in "${steps[@]}"; do
  echo "==> $step"
  bash "$DIR/$step"
done

echo "Done. Restart your terminal."
