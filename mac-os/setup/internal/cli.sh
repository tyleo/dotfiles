#!/usr/bin/env bash
# Tools fetched straight from their vendors over curl - an install script or the
# tool's own binary - rather than via Homebrew, the App Store, or a language
# toolchain. Each one self-updates after first install, which is the whole point of
# installing them this way: they stay current on their own instead of waiting on a
# package manager to catch up. Entries are ABC-ordered by tool name.
set -euo pipefail

# Claude Code - Anthropic's CLI (not the Claude desktop app, which is in
# apps-manual.sh). Native installer; needs a Claude subscription or API credits.
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Oh My Zsh - zsh config framework. Unattended (no shell launch, no chsh prompt)
# and KEEP_ZSHRC=yes so it never clobbers a dotfiles-managed ~/.zshrc. Run before
# your dotfiles write ~/.zshrc, or have ~/.zshrc source $ZSH/oh-my-zsh.sh.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# yt-dlp - audio/video downloader. The brew formula lags upstream by months and
# installs it as a pip wheel, which makes "yt-dlp -U" refuse to self-update; the
# official standalone binary self-updates cleanly, so install that into ~/.local/bin:
# user-writable (so "yt-dlp -U" needs no sudo) and already on PATH, where it shadows
# any leftover brew copy. The "latest" URL grabs the newest release at install time;
# from then on the "--update" line in the yt-dlp config (kept as a dotfile at
# mac-os/yt-dlp/config, deployed to ~/.config/yt-dlp/config) self-updates it to the
# latest stable on every run. Needs ffmpeg (in the Brewfile) to merge audio/video.
if [ ! -x "$HOME/.local/bin/yt-dlp" ]; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos -o "$HOME/.local/bin/yt-dlp"
  chmod +x "$HOME/.local/bin/yt-dlp"
fi
