#!/usr/bin/env bash
# Tools fetched straight from their vendors over curl - an install script or the
# tool's own binary - rather than via Homebrew, the App Store, or a language
# toolchain. Each one self-updates after first install, which is the whole point
# of installing them this way: they stay current on their own instead of waiting
# on a package manager to catch up. Entries are ABC-ordered by tool name.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# The Oh My Zsh installer below clones itself with git and aborts ("git is not
# installed") if git is missing. git ships with the Xcode Command Line Tools
# that the Homebrew installer sets up, so ensure that foundation is present
# first (no-op once it exists).
ensure_brew

# Claude Code - Anthropic's CLI (not the Claude desktop app, which is in
# apps-manual.sh). Native installer; needs a Claude subscription or API credits.
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Oh My Zsh - zsh config framework. Unattended (no shell launch, no chsh prompt)
# and KEEP_ZSHRC=yes so it never clobbers a dotfiles-managed ~/.zshrc. Run
# before your dotfiles write ~/.zshrc, or have ~/.zshrc source
# $ZSH/oh-my-zsh.sh.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Oh My Zsh custom plugins - the third-party plugins ~/.zshrc enables in
# plugins=() but Oh My Zsh does not bundle (git is bundled, these are not), so
# clone each into $ZSH_CUSTOM/plugins by hand. Runs after the Oh My Zsh install
# above, which creates that directory. $ZSH_CUSTOM is only exported once
# ~/.zshrc sources Oh My Zsh, so fall back to its default here. fzf-tab also
# needs the fzf binary, which the Brewfile installs. Each row is a "<name>" line
# then its "<url>" line; install_rows clones each. Entries are ABC-ordered by
# name.

# Clone one plugin into $ZSH_CUSTOM/plugins/<name>, unless it is already there.
# The functor for the install_rows loop below.
install_zsh_plugin() {
  local dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$(dirname "$dir")"
    git clone --depth=1 "$2" "$dir"
  fi
}

zsh_plugins=(
  "fzf-tab"
  "https://github.com/Aloxaf/fzf-tab"

  "zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-autosuggestions"

  "zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
)

install_rows 2 install_zsh_plugin "${zsh_plugins[@]}"

# yt-dlp - audio/video downloader. The brew formula lags upstream by months and
# installs it as a pip wheel, which makes "yt-dlp -U" refuse to self-update; the
# official standalone binary self-updates cleanly, so install that into
# ~/.local/bin: user-writable (so "yt-dlp -U" needs no sudo) and already on
# PATH, where it shadows any leftover brew copy. The "latest" URL grabs the
# newest release at install time; from then on the "--update" line in the
# yt-dlp config (kept as a dotfile at mac-os/.config/yt-dlp/config, deployed to
# ~/.config/yt-dlp/config) self-updates it to the latest stable on every run.
# Needs ffmpeg (in the Brewfile) to merge audio/video.
if [ ! -x "$HOME/.local/bin/yt-dlp" ]; then
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos -o "$HOME/.local/bin/yt-dlp"
  chmod +x "$HOME/.local/bin/yt-dlp"
fi
