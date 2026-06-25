#!/usr/bin/env bash
# Tools installed from their vendors' own curl install scripts (not Homebrew, the
# App Store, or a language toolchain). Both self-update after first install.
set -euo pipefail

# Claude Code - Anthropic's CLI (not the Claude desktop app, which is in
# manual-apps.sh). Native installer; needs a Claude subscription or API credits.
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# Oh My Zsh - zsh config framework. Unattended (no shell launch, no chsh prompt)
# and KEEP_ZSHRC=yes so it never clobbers a dotfiles-managed ~/.zshrc. Run before
# your dotfiles write ~/.zshrc, or have ~/.zshrc source $ZSH/oh-my-zsh.sh.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
