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
  "$REPO/mac-os/.claude/file-suggestion.sh"
  "$HOME/.claude/file-suggestion.sh"

  "$REPO/mac-os/.claude/settings.json"
  "$HOME/.claude/settings.json"

  "$REPO/mac-os/.claude/statusline.sh"
  "$HOME/.claude/statusline.sh"

  "$REPO/mac-os/.config/ghostty/config"
  "$HOME/.config/ghostty/config"

  "$REPO/mac-os/.config/karabiner/karabiner.json"
  "$HOME/.config/karabiner/karabiner.json"

  "$REPO/mac-os/.config/yt-dlp/config"
  "$HOME/.config/yt-dlp/config"

  "$REPO/mac-os/.gitconfig"
  "$HOME/.gitconfig"

  "$REPO/mac-os/.zprofile"
  "$HOME/.zprofile"

  "$REPO/mac-os/.zshenv"
  "$HOME/.zshenv"

  "$REPO/mac-os/.zshrc"
  "$HOME/.zshrc"

  "$REPO/shared/starship/starship.toml"
  "$HOME/.config/starship.toml"

  "$REPO/shared/vim/.vimrc"
  "$HOME/.vimrc"

  "$REPO/shared/visual_studio_code/settings.json"
  "$VSCODE/settings.json"
)

install_rows 2 install_dotfile "${items[@]}"
