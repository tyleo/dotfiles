#!/usr/bin/env bash

# Deploy the tracked dotfiles into `$HOME`.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# Repo root, located via `git` so it survives moving this script.
REPO="$(git -C "$DIR" rev-parse --show-toplevel)"

# VS Code keeps its user config under Application Support, not a dotfile path.
VSCODE="$HOME/Library/Application Support/Code/User"

items=(
  "$REPO/mac-os/usr/.claude/file-suggestion.sh"
  "$HOME/.claude/file-suggestion.sh"

  "$REPO/mac-os/usr/.claude/settings.json"
  "$HOME/.claude/settings.json"

  "$REPO/mac-os/usr/.claude/statusline.sh"
  "$HOME/.claude/statusline.sh"

  "$REPO/mac-os/usr/.config/ghostty/config"
  "$HOME/.config/ghostty/config"

  "$REPO/mac-os/usr/.config/karabiner/karabiner.json"
  "$HOME/.config/karabiner/karabiner.json"

  "$REPO/mac-os/usr/.config/yt-dlp/config"
  "$HOME/.config/yt-dlp/config"

  "$REPO/mac-os/usr/.gitconfig"
  "$HOME/.gitconfig"

  "$REPO/mac-os/usr/.zprofile"
  "$HOME/.zprofile"

  "$REPO/mac-os/usr/.zshenv"
  "$HOME/.zshenv"

  "$REPO/mac-os/usr/.zshrc"
  "$HOME/.zshrc"

  "$REPO/mac-os/usr/.config/starship.toml"
  "$HOME/.config/starship.toml"

  "$REPO/shared/usr/.vimrc"
  "$HOME/.vimrc"

  "$REPO/shared/apps/visual-studio-code/settings.json"
  "$VSCODE/settings.json"
)

install_rows 2 install_dotfile "${items[@]}"
