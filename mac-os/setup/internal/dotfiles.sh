#!/usr/bin/env bash
# Deploy the tracked dotfiles into $HOME. Runs last (see setup.sh): it lays the
# managed shell rc files down over whatever nvm/rustup/brew appended to them, so
# the repo's copies win instead of accumulating duplicate snippets.
# install_dotfile skips files already in sync and backs up any differing live
# file to "<dest>.bak" first.
#
# Each row is a "<source>" line (inside the repo) followed by its
# "<destination>" line (under $HOME). dotfiles holds those pairs and
# install_rows deploys each. Entries are ABC-ordered by source path.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# Repo root is three levels up from internal/
# (internal -> setup -> mac-os -> repo).
REPO="$(cd "$DIR/../../.." && pwd)"
# VS Code keeps its user config under Application Support, not a dotfile path.
VSCODE="$HOME/Library/Application Support/Code/User"

dotfiles=(
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

install_rows 2 install_dotfile "${dotfiles[@]}"
