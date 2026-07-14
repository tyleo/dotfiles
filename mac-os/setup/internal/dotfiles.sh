#!/usr/bin/env bash

# Deploy the tracked dotfiles into `$HOME`.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# Repo root, located via `git` so it survives moving this script.
REPO="$(git -C "$DIR" rev-parse --show-toplevel)"

items=(
  "$REPO/mac-os/usr/.claude/file-suggestion.sh"
  "$HOME/.claude/file-suggestion.sh"

  "$REPO/mac-os/usr/.claude/settings.json"
  "$HOME/.claude/settings.json"

  "$REPO/shared/usr/.claude/skills/comment-cleanup/SKILL.md"
  "$HOME/.claude/skills/comment-cleanup/SKILL.md"

  "$REPO/mac-os/usr/.claude/statusline.sh"
  "$HOME/.claude/statusline.sh"

  "$REPO/mac-os/usr/.config/ghostty/config"
  "$HOME/.config/ghostty/config"

  "$REPO/mac-os/usr/.config/herdr/config.toml"
  "$HOME/.config/herdr/config.toml"

  "$REPO/mac-os/usr/.config/karabiner/karabiner.json"
  "$HOME/.config/karabiner/karabiner.json"

  "$REPO/mac-os/usr/.config/starship.toml"
  "$HOME/.config/starship.toml"

  "$REPO/mac-os/usr/.config/yt-dlp/config"
  "$HOME/.config/yt-dlp/config"

  "$REPO/mac-os/usr/.gitconfig"
  "$HOME/.gitconfig"

  "$REPO/shared/usr/.vimrc"
  "$HOME/.vimrc"

  "$REPO/mac-os/usr/.zprofile"
  "$HOME/.zprofile"

  "$REPO/mac-os/usr/.zshenv"
  "$HOME/.zshenv"

  "$REPO/mac-os/usr/.zshrc"
  "$HOME/.zshrc"
)

install_rows 2 install_dotfile "${items[@]}"
