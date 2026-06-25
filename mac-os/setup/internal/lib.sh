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

# Load nvm into the current shell. The installer only edits shell rc files, so
# steps that need `nvm`/`node` in the running session must source it first.
ensure_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

# Download a zipped macOS app and install it into /Applications, unless it is
# already there. Apps installed this way keep their own built-in updater (no
# Homebrew, nothing external tracking the install). Args:
#   $1 - app name as it appears in /Applications, without the ".app" suffix
#   $2 - URL serving a .zip that contains the .app bundle
install_app_zip() {
  local name="$1" url="$2"
  local app="/Applications/$name.app"
  if [ -d "$app" ]; then
    return
  fi

  echo "Downloading $name..."
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/app.zip"
  ditto -x -k "$tmp/app.zip" /Applications
  rm -rf "$tmp"
}
