#!/usr/bin/env bash

# Install the Rust toolchain via `rustup` and the `cargo` crates below.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew

if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

ensure_cargo

# A default `rustup` install only fetches the host's std, so add the cross
# targets the crates below build for.
rustup target add aarch64-linux-android wasm32-unknown-unknown

install_crate() { cargo install "$1"; }

items=(
  cargo-ndk

  cargo-workspaces

  tyt

  tyt-vmax

  wasm-bindgen-cli
)

install_rows 1 install_crate "${items[@]}"
