#!/usr/bin/env bash

# Register default apps for file types with Launch Services. Each row binds
# one extension or UTI to the app that opens it. The plain-text UTI row covers
# text-like types with no row of their own.
#
# Notes:
#   1. Runs after the app installers. Launch Services only binds installed
#      apps.
#   2. Applies rows with the set_default_app_by_id_* functions from the repo
#      .zshrc, so the duti invocation lives in one place and the step does not
#      depend on dotfiles.sh.
#   3. An extension with only a dynamic UTI fails with error -50 and is
#      skipped. An app that claims it in its Info.plist still opens it. VS
#      Code claims .jsx this way.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

if ! command -v duti &>/dev/null; then
  ensure_brew
  brew install duti
fi

ZSHRC="$(cd "$DIR/../../usr" && pwd)/.zshrc"

# Rows: extension with dot or UTI, then the bundle id that opens it.
items=(
  .js com.microsoft.VSCode
  .jsx com.microsoft.VSCode
  .md com.microsoft.VSCode
  .ts com.microsoft.VSCode
  .tsx com.microsoft.VSCode
  .txt com.microsoft.VSCode
  public.plain-text com.microsoft.VSCode
)

zsh -c '
  source "$1" >/dev/null 2>&1 || true
  shift
  while (($#)); do
    if [[ "$1" == .* ]]; then
      set_default_app_by_id_for_extension "$1" "$2" || true
    else
      set_default_app_by_id_for_uti "$1" "$2" || true
    fi
    shift 2
  done
' _ "$ZSHRC" "${items[@]}"
