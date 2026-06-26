#!/usr/bin/env bash

# Oh My Zsh custom plugins - the third-party plugins `~/.zshrc` enables in
# `plugins=()` but Oh My Zsh does not bundle, so clone each into
# `$ZSH_CUSTOM/plugins` by hand. Meant to run after `cli.sh` installs Oh My Zsh,
# which creates that directory. `$ZSH_CUSTOM` is only exported once `~/.zshrc`
# sources Oh My Zsh, so fall back to its default here.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

ensure_brew

# Clone one plugin into `$ZSH_CUSTOM/plugins/<name>`, unless it is already
# there.
install_zsh_plugin() {
  local dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$(dirname "$dir")"
    git clone --depth=1 "$2" "$dir"
  fi
}

items=(
  "fzf-tab"
  "https://github.com/Aloxaf/fzf-tab"

  "zsh-autosuggestions"
  "https://github.com/zsh-users/zsh-autosuggestions"

  "zsh-syntax-highlighting"
  "https://github.com/zsh-users/zsh-syntax-highlighting"
)

install_rows 2 install_zsh_plugin "${items[@]}"
