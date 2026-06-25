#!/usr/bin/env bash
# Apps whose only download sits behind a bot challenge (e.g. Cloudflare). We do
# not work around that, so this just prints a reminder to install each by hand
# if it is missing. Apps with a clean direct download live in apps.sh.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# Claude desktop app.
warn_manual_install "Claude" "https://claude.ai/download"

# Codex app.
warn_manual_install "Codex" "https://chatgpt.com/codex"
