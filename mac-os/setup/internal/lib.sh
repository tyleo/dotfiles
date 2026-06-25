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

# Like install_app_zip, but for apps shipped as a .dmg disk image: mount the
# image on a private mountpoint, copy the .app out into /Applications, then
# unmount. Skipped if the app is already installed. Args:
#   $1 - app name as it appears in /Applications, without the ".app" suffix
#        (must match the .app bundle name inside the disk image)
#   $2 - URL serving a .dmg that contains the .app bundle
install_app_dmg() {
  local name="$1" url="$2"
  local app="/Applications/$name.app"
  if [ -d "$app" ]; then
    return
  fi

  echo "Downloading $name..."
  local tmp mnt
  tmp="$(mktemp -d)"
  mnt="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/app.dmg"
  hdiutil attach -nobrowse -quiet -mountpoint "$mnt" "$tmp/app.dmg"
  cp -R "$mnt/$name.app" /Applications/
  hdiutil detach -quiet "$mnt"
  rm -rf "$tmp" "$mnt"
}

# Print a reminder to install an app by hand, unless it is already in
# /Applications. Used for apps whose only download sits behind a bot challenge:
# rather than working around that protection, just point the user at the page.
# Args:
#   $1 - app name as it appears in /Applications, without the ".app" suffix
#   $2 - URL the user should open to download it
warn_manual_install() {
  local name="$1" url="$2"
  if [ -d "/Applications/$name.app" ]; then
    return
  fi
  echo "Manual install needed: $name is not in /Applications. Download it from $url"
}
