#!/usr/bin/env bash
# Shared helpers for the setup steps. Source this file; do not execute it.
# Functions are kept in alphabetical order.

# Put Homebrew on PATH for the current shell, installing it first if it is missing.
# The installer does not touch the running session, so any step that needs `brew`
# calls this and gets a working brew no matter what order the steps run in. Covers
# Apple Silicon (/opt/homebrew) and Intel (/usr/local).
ensure_brew() {
  if command -v brew &>/dev/null; then
    return
  fi
  if [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Download a macOS app shipped as a .dmg disk image and install it into
# /Applications, unless it is already there: mount the image on a private
# mountpoint, copy the .app out, then unmount. Apps installed this way keep their
# own built-in updater (no Homebrew, nothing external tracking the install). Args:
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

# Like install_app_dmg, but for apps shipped as a .zip. Extracts the zip and
# copies "<name>.app" into /Applications, whether the bundle sits at the zip root
# or one folder down (some zips wrap it in a folder). Skips the download if the
# app is already installed. Args:
#   $1 - app name as it appears in /Applications, without the ".app" suffix
#   $2 - URL serving a .zip that contains the .app bundle
install_app_zip() {
  local name="$1" url="$2"
  local app="/Applications/$name.app"
  if [ -d "$app" ]; then
    return
  fi

  echo "Downloading $name..."
  local tmp found
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/app.zip"
  ditto -x -k "$tmp/app.zip" "$tmp/unpacked"
  found="$(find "$tmp/unpacked" -maxdepth 2 -type d -name "$name.app" -print -quit)"
  if [ -z "$found" ]; then
    echo "ERROR: $name.app not found in zip from $url" >&2
    rm -rf "$tmp"
    return 1
  fi
  cp -R "$found" /Applications/
  rm -rf "$tmp"
}

# Call an installer once per item of a flat list (one argument per call). The
# width-1 shortcut for install_rows: use it for single-field lists - crates,
# extensions - where there is nothing to pair up. Args:
#   $1   - name of the installer function to call per item
#   $2.. - the items
install_each() {
  install_rows 1 "$@"
}

# Call an installer once per (a, b) pair of a flat list (a1 b1 a2 b2 ...). The
# width-2 shortcut for install_rows. Args:
#   $1   - name of the installer function to call per pair
#   $2.. - the flat list, two elements per row (a1 b1 a2 b2 ...)
install_pairs() {
  install_rows 2 "$@"
}

# Install a command-line tool from a vendor's signed .pkg, unless that exact
# version is already on PATH. Microsoft signs and notarizes the PowerShell pkg, so
# `installer` runs it with no Gatekeeper bypass (no -allowUntrusted). These tools
# do not self-update, so the version passed here is the source of truth: bump it and
# the URL together and the next run upgrades in place (installer replaces the files).
# Args:
#   $1 - display name, for the status messages
#   $2 - command the package installs; "$cmd --version" is matched against $3
#   $3 - version string expected in "$cmd --version" output; skipped if it matches
#   $4 - URL serving the .pkg
install_pkg() {
  local name="$1" cmd="$2" version="$3" url="$4"
  if command -v "$cmd" &>/dev/null && "$cmd" --version 2>/dev/null | grep -qF "$version"; then
    return
  fi

  echo "Installing $name $version..."
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "$url" -o "$tmp/pkg.pkg"
  sudo installer -pkg "$tmp/pkg.pkg" -target /
  rm -rf "$tmp"
}

# Call an installer once per row of a flat list, passing each row's fields as
# arguments. bash has no nested arrays, so rows are stored flat - the fields of
# each row laid end to end (r1f1 r1f2 ... r2f1 r2f2 ...) - and install_rows slices
# them back into one call per row. Keep a row's fields together in the source (a
# comment above, one field per line) so each row reads as one unit. A leftover
# count that is not a whole number of rows means a field was dropped, reported up
# front instead of silently shifting every later row. Args:
#   $1   - fields per row (the arity the installer expects)
#   $2   - name of the installer function to call per row
#   $3.. - the flat list, $1 elements per row
install_rows() {
  local width="$1" fn="$2"
  shift 2
  if (($# % width)); then
    echo "install_rows: $fn list has $# elements, not a whole number of $width-field rows" >&2
    return 1
  fi
  while (($#)); do
    "$fn" "${@:1:width}"
    shift "$width"
  done
}

# Install a Mac App Store app by id, unless it is already installed. Requires
# being signed in to the App Store with the app in your purchase history; mas can
# no longer sign in from the CLI. Args:
#   $1 - human-readable name, for the status messages
#   $2 - numeric App Store id
mas_install() {
  local name="$1" id="$2"
  if mas list | grep -q "^$id"; then
    echo "$name already installed."
  elif ! mas install "$id"; then
    echo "Could not install $name. Sign in to the App Store, then run: mas install $id" >&2
  fi
}

# Print a reminder to install an app by hand, unless it is already in
# /Applications. Used for anything we do not auto-install: downloads behind a bot
# challenge, paid apps we do not script, or apps with an ambiguous source. Just
# points the user at the download page. Args:
#   $1 - app name as it appears in /Applications, without the ".app" suffix
#   $2 - URL the user should open to download it
warn_manual_install() {
  local name="$1" url="$2"
  if [ -d "/Applications/$name.app" ]; then
    return
  fi
  echo "Manual install needed: $name is not in /Applications. Download it from $url"
}
