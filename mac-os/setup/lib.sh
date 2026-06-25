#!/usr/bin/env bash
# Shared helpers for the setup steps. Source this file; do not execute it.

# Put Homebrew on PATH for the current shell. The installer does not touch the
# running session, so steps that need `brew` call this first. Covers Apple
# Silicon (/opt/homebrew) and Intel (/usr/local).
ensure_brew() {
  if command -v brew &>/dev/null; then
    return
  fi
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# Put cargo on PATH if rustup installed it into ~/.cargo.
ensure_cargo() {
  if ! command -v cargo &>/dev/null && [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi
}
