#!/usr/bin/env bash
# Install the Rust toolchain (via rustup) and the cargo crates below.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# cargo install compiles each crate from source, which needs a C compiler and
# linker. Those ship with the Xcode Command Line Tools that the Homebrew
# installer sets up, so make sure that foundation is in place before building
# (no-op once it exists).
ensure_brew

if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
ensure_cargo

# wasm-bindgen-cli (below) compiles against the wasm32-unknown-unknown target,
# but a default rustup install only fetches the host's std. Add that target's
# std so wasm crates can build against it; rustup makes this a no-op once it is
# present.
rustup target add wasm32-unknown-unknown

# Install one crate. The functor for the install_rows loop below.
install_crate() { cargo install "$1"; }

cargo_crates=(
  cargo-workspaces

  tyt

  tyt-vmax

  wasm-bindgen-cli
)

install_rows 1 install_crate "${cargo_crates[@]}"
