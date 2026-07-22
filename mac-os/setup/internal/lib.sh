#!/usr/bin/env bash

# Shared helpers for the setup steps. Source this file; do not execute it.
# Functions are kept in alphabetical order.

# Put Homebrew on PATH for the current shell, installing it first if it is
# missing. The installer does not touch the running session, so any step that
# needs `brew` calls this and gets a working `brew` no matter what order the
# steps run in.
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

# Put `cargo` on PATH if `rustup` installed it into `~/.cargo`.
ensure_cargo() {
  if ! command -v cargo &>/dev/null && [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi
}

# Load `nvm` into the current shell. The installer only edits shell rc files, so
# steps that need `nvm`/`node` in the running session must source it first.
ensure_nvm() {
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  # shellcheck disable=SC1091
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

# Download a macOS app shipped as a `.dmg` disk image and install it into
# `/Applications`, unless it is already there: mount the image on a private
# mountpoint, copy the `.app` out, then unmount. Apps installed this way keep
# their own built-in updater (no Homebrew, nothing external tracking the
# install).
#
# Args:
# $1 - app name as it appears in `/Applications`, without the `.app` suffix
# $2 - URL serving a `.dmg` that contains the `.app` bundle
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

# Like `install_app_dmg`, but for apps shipped as a `.zip`. Extracts the zip
# and copies `<name>.app` into `/Applications`, whether the bundle sits at
# the zip root or one folder down. Skips the download if the app is already
# installed.
#
# Args:
# $1 - app name as it appears in `/Applications`, without the `.app` suffix
# $2 - URL serving a `.zip` that contains the `.app` bundle
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

# Copy a tracked dotfile from the repo to its place under `$HOME`, creating any
# missing parent directories. The repo is the source of truth, so this
# overwrites the live file - but it skips the copy when the two already match
# and backs up any differing live file to `<dest>.bak` first, so a stray local
# edit that was never synced back is not lost.
#
# Args:
# $1 - path to the dotfile inside the repo
# $2 - path it deploys to
install_dotfile() {
  local src="$1" dest="$2"
  if [ ! -f "$src" ]; then
    echo "ERROR: dotfile source missing: $src" >&2
    return 1
  fi
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    cp "$dest" "$dest.bak"
    echo "Backed up existing $dest to $dest.bak"
  fi
  cp "$src" "$dest"
  echo "Installed $dest"
}

# Install a command-line tool from a vendor's signed `.pkg`, unless that exact
# version is already on PATH. These tools do not self-update, so the version
# passed here is the source of truth: bump it and the URL together and the next
# run upgrades in place.
#
# Args:
# $1 - display name, for the status messages
# $2 - command the package installs; `"$cmd --version"` is matched against `$3`
# $3 - version string expected in `"$cmd --version"` output; skipped if it
#      matches
# $4 - URL serving the `.pkg`
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
# each row laid end to end (r1f1 r1f2 ... r2f1 r2f2 ...) - and `install_rows`
# slices them back into one call per row. A leftover count that is not a whole
# number of rows means a field was dropped, reported up front instead of
# silently shifting every later row.
#
# Args:
# $1   - fields per row
# $2   - name of the installer function to call per row
# $3.. - the flat list, `$1` elements per row
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

# Symlink a binary that lives inside an installed `.app` into `~/.local/bin`,
# which is already on PATH, so its short name runs from anywhere. Skips the link
# when it already points at the right target and refreshes a stale one. Warns
# and moves on when the source binary is missing, so an app that is not
# installed yet does not fail the run.
#
# Args:
# $1 - command name to create under `~/.local/bin`
# $2 - path to the binary inside `/Applications`
link_app_bin() {
  local name="$1" src="$2"
  local dest="$HOME/.local/bin/$name"
  if [ ! -x "$src" ]; then
    echo "Skipping $name: source binary missing: $src" >&2
    return
  fi
  if [ "$(readlink "$dest")" = "$src" ]; then
    return
  fi
  mkdir -p "$HOME/.local/bin"
  ln -sf "$src" "$dest"
  echo "Linked $name -> $src"
}

# Install a Mac App Store app by id, unless it is already installed. Requires
# being signed in to the App Store with the app in your purchase history; `mas`
# can no longer sign in from the CLI.
#
# Args:
# $1 - human-readable name, for the status messages
# $2 - numeric App Store id
mas_install() {
  local name="$1" id="$2"
  if mas list | grep -q "^$id"; then
    echo "$name already installed."
  elif ! mas install "$id"; then
    echo "Could not install $name. Sign in to the App Store, then run: mas install $id" >&2
  fi
}

# Deep-merge a tracked JSON dotfile into the live one instead of overwriting
# it, so machine-local keys survive a deploy. Tracked keys win on conflict;
# nested objects merge recursively, arrays and scalars replace whole. Writes
# jq's sorted-key format so repeat runs are no-ops, and backs up a differing
# live file to `<dest>.bak` first, like `install_dotfile`.
#
# Args:
# $1 - path to the JSON dotfile inside the repo
# $2 - path it deploys to
merge_json_dotfile() {
  local src="$1" dest="$2"
  if [ ! -f "$src" ]; then
    echo "ERROR: dotfile source missing: $src" >&2
    return 1
  fi
  if [ ! -f "$dest" ]; then
    install_dotfile "$src" "$dest"
    return
  fi
  if ! jq empty "$dest" 2>/dev/null; then
    echo "ERROR: $dest is not valid JSON; fix it and rerun" >&2
    return 1
  fi
  local merged
  if ! merged="$(jq -S -s '.[0] * .[1]' "$dest" "$src")"; then
    echo "ERROR: could not merge $src into $dest" >&2
    return 1
  fi
  if [ "$merged" = "$(cat "$dest")" ]; then
    return
  fi
  cp "$dest" "$dest.bak"
  echo "Backed up existing $dest to $dest.bak"
  printf '%s\n' "$merged" >"$dest.tmp"
  mv "$dest.tmp" "$dest"
  echo "Merged $dest"
}

# Copy a tracked default into place only when the destination is missing. For
# runtime-state files: the repo seeds the first value and the machine owns
# every change after that, so an existing file is never touched.
#
# Args:
# $1 - path to the default inside the repo
# $2 - path it seeds
seed_dotfile() {
  local src="$1" dest="$2"
  if [ -f "$dest" ]; then
    return
  fi
  install_dotfile "$src" "$dest"
}

# Help install an app we do not fully automate, unless it is already in
# `/Applications`. If the URL is a direct installer file (.pkg/.dmg/.zip), grab
# it into ~/Downloads so the user only has to open it; we stop short of running
# it because the last step (sign-in, license, drag-to-Applications) is manual.
# If the URL is a landing page or sits behind a bot gate there is no single file
# to fetch, so we just print the link - we never try to defeat a bot challenge.
#
# Args:
# $1 - app name as it appears in `/Applications`, without the `.app` suffix
# $2 - direct installer URL when one exists, otherwise a download page
warn_manual_install() {
  local name="$1" url="$2"
  if [ -d "/Applications/$name.app" ]; then
    return
  fi

  # Peek with a HEAD so we can tell a real installer from a web page without
  # pulling the whole page down. A bot gate or unsupported HEAD leaves this
  # empty, which falls through to the printed reminder below.
  local info ctype fname dest
  if info="$(curl -fsIL -o /dev/null -w '%{content_type}\t%{url_effective}' "$url" 2>/dev/null)"; then
    ctype="${info%%$'\t'*}"
    fname="${info##*/}"
    fname="${fname%%\?*}"
    case "$ctype:$fname" in
    *html*) ;; # a web page, not a file - fall through to the reminder
    *.pkg | *.mpkg | *.dmg | *.zip)
      dest="$HOME/Downloads/$fname"
      if [ -f "$dest" ]; then
        echo "$name installer already downloaded at $dest. Open it to finish installing."
        return
      fi
      echo "Downloading $name installer to $dest ..."
      mkdir -p "$HOME/Downloads"
      if curl -fL --progress-bar "$url" -o "$dest"; then
        echo "Downloaded $name. Open $dest to finish installing; sign-in/license is manual."
        return
      fi
      rm -f "$dest"
      ;;
    esac
  fi

  echo "Manual install needed: $name is not in /Applications. Download it from $url"
}

# Remind us to install an app distributed through Steam, unless its Steam
# library manifest is already present. Steam keeps these in its own library
# (not `/Applications`) and updates them itself, and the client will not install
# them without a signed-in session, so this only nudges: it prints a `steam://`
# link that opens the store page right in the Steam app.
#
# Args:
# $1 - app name, for the reminder
# $2 - numeric Steam app id
warn_steam_install() {
  local name="$1" id="$2"
  if [ -f "$HOME/Library/Application Support/Steam/steamapps/appmanifest_$id.acf" ]; then
    return
  fi
  echo "Manual install needed: $name is not in your Steam library. Install it from Steam: steam://store/$id (https://store.steampowered.com/app/$id/)"
}
