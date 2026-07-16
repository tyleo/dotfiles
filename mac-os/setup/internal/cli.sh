#!/usr/bin/env bash

# Tools fetched straight from their vendors over `curl`.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# The Oh My Zsh installer below clones itself with `git` and aborts if `git` is
# missing. `git` ships with the Xcode Command Line Tools that the Homebrew
# installer sets up, so ensure that foundation is present.
ensure_brew

# Claude Code - Anthropic's CLI.
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# herdr - terminal multiplexer for coding agents. Installs to ~/.local/bin and
# self-updates.
if ! command -v herdr &>/dev/null; then
  curl -fsSL https://herdr.dev/install.sh | sh
fi

# herdr plugins. The fresh install lands in ~/.local/bin, which may not be on
# PATH in this shell, so call the binary by path.
HERDR="$HOME/.local/bin/herdr"
if ! "$HERDR" plugin list 2>/dev/null | grep -q herdr-file-viewer; then
  "$HERDR" plugin install smarzban/herdr-file-viewer --yes
fi

# Oh My Zsh - zsh config framework. Unattended and `KEEP_ZSHRC=yes` so it never
# clobbers a dotfiles-managed `~/.zshrc`. Run before your dotfiles write
# `~/.zshrc`, or have `~/.zshrc` source `$ZSH/oh-my-zsh.sh`.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# yt-dlp - audio/video downloader.
if [ ! -x "$HOME/.local/bin/yt-dlp" ]; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos -o "$HOME/.local/bin/yt-dlp"
  chmod +x "$HOME/.local/bin/yt-dlp"
fi
