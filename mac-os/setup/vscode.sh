#!/usr/bin/env bash
# Install VS Code extensions. Requires the `code` CLI on PATH (in VS Code:
# Cmd-Shift-P -> "Shell Command: Install 'code' command in PATH").
set -euo pipefail

if ! command -v code &>/dev/null; then
  echo "WARNING: 'code' CLI not found — skipping VS Code extensions."
  echo "         Install VS Code + its shell command, then re-run this script."
  exit 0
fi

vscode_extensions=(
  anthropic.claude-code
  dbaeumer.vscode-eslint
  eamodio.gitlens
  esbenp.prettier-vscode
  fill-labs.dependi
  github.copilot
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

for ext in "${vscode_extensions[@]}"; do
  code --install-extension "$ext" --force
done
