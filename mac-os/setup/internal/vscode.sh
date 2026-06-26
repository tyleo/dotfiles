#!/usr/bin/env bash

# Install VS Code and the extensions below.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

install_app_zip "Visual Studio Code" \
  "https://update.code.visualstudio.com/latest/darwin-universal/stable"

# Use the `code` CLI from PATH if present, otherwise the one in the app bundle.
BUNDLED_CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if command -v code &>/dev/null; then
  code="$(command -v code)"
elif [ -x "$BUNDLED_CODE" ]; then
  code="$BUNDLED_CODE"
else
  echo "ERROR: \`code\` CLI not found after install, aborting." >&2
  exit 1
fi

install_extension() { "$code" --install-extension "$1" --force; }

items=(
  anthropic.claude-code

  dbaeumer.vscode-eslint

  eamodio.gitlens

  esbenp.prettier-vscode

  fill-labs.dependi

  mechatroner.rainbow-csv

  ms-dotnettools.csdevkit

  ms-dotnettools.csharp

  ms-dotnettools.vscode-dotnet-runtime

  ms-vscode.hexeditor

  ms-vscode.powershell

  rust-lang.rust-analyzer

  shd101wyy.markdown-preview-enhanced

  simonsiefke.svg-preview

  slevesque.shader

  soltys.vscode-il

  streetsidesoftware.code-spell-checker

  tamasfe.even-better-toml

  ue.alphabetical-sorter

  vscode-icons-team.vscode-icons

  vscodevim.vim
  
  zxh404.vscode-proto3
)

install_rows 1 install_extension "${items[@]}"
