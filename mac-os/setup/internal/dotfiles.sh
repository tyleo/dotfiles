#!/usr/bin/env bash

# Deploy the tracked dotfiles into `$HOME`.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# Repo root, located via `git` so it survives moving this script.
REPO="$(git -C "$DIR" rev-parse --show-toplevel)"

items=(
  "$REPO/shared/usr/.agents/skills/comment-cleanup/SKILL.md"
  "$HOME/.agents/skills/comment-cleanup/SKILL.md"

  "$REPO/shared/usr/.agents/skills/pr-walkthrough/SKILL.md"
  "$HOME/.agents/skills/pr-walkthrough/SKILL.md"

  "$REPO/shared/usr/.agents/skills/prose-cleanup/SKILL.md"
  "$HOME/.agents/skills/prose-cleanup/SKILL.md"

  "$REPO/mac-os/usr/.claude/file-suggestion.sh"
  "$HOME/.claude/file-suggestion.sh"

  "$REPO/mac-os/usr/.claude/statusline.sh"
  "$HOME/.claude/statusline.sh"

  "$REPO/mac-os/usr/.claude/statusline/README.md"
  "$HOME/.claude/statusline/README.md"

  "$REPO/mac-os/usr/.claude/statusline/directory.sh"
  "$HOME/.claude/statusline/directory.sh"

  "$REPO/mac-os/usr/.claude/statusline/effort.sh"
  "$HOME/.claude/statusline/effort.sh"

  "$REPO/mac-os/usr/.claude/statusline/git.sh"
  "$HOME/.claude/statusline/git.sh"

  "$REPO/mac-os/usr/.claude/statusline/long-context.sh"
  "$HOME/.claude/statusline/long-context.sh"

  "$REPO/mac-os/usr/.claude/statusline/model.sh"
  "$HOME/.claude/statusline/model.sh"

  "$REPO/mac-os/usr/.claude/statusline/short-context.sh"
  "$HOME/.claude/statusline/short-context.sh"

  "$REPO/mac-os/usr/.claude/statusline/usage.sh"
  "$HOME/.claude/statusline/usage.sh"

  "$REPO/mac-os/usr/.claude/statuslineconfig.json"
  "$HOME/.claude/statuslineconfig.json"

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

# The skills live in `~/.agents/skills`, the directory every agent shares, and
# Claude Code reads them through this link.
link_dir ../.agents/skills "$HOME/.claude/skills"

# Merged rather than copied, so machine-local keys survive the deploy.
merge_json_dotfile "$REPO/mac-os/usr/.claude/settings.json" "$HOME/.claude/settings.json"
