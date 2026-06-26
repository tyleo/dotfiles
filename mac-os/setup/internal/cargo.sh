#!/usr/bin/env bash
# Install the Rust toolchain (via rustup) and the cargo crates below.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
ensure_cargo

# Install one crate. The functor for the install_rows loop below.
install_crate() { cargo install "$1"; }

cargo_crates=(
  cargo-workspaces
  tyt
  tyt-vmax
  wasm-bindgen-cli
)

install_rows 1 install_crate "${cargo_crates[@]}"
