#!/usr/bin/env bash

# Force the tracked codex statusline settings into `~/.codex/config.toml`.
# codex owns every other key in that file, so this merges rather than copies:
# 1. drop any status_line already in the [tui] section
# 2. splice the tracked array in right after the [tui] header, adding the
#    header at the end of the file when it is missing
# The fragment becomes the whole file when no config exists yet. Safe to
# rerun any time the statusline needs forcing back on.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Repo root, located via `git` so it survives moving this script.
REPO="$(git -C "$DIR" rev-parse --show-toplevel)"

FRAGMENT="$REPO/mac-os/usr/.codex/statusline.toml"
CONFIG="$HOME/.codex/config.toml"

if [ ! -f "$CONFIG" ]; then
  mkdir -p "$(dirname "$CONFIG")"
  cp "$FRAGMENT" "$CONFIG"
  echo "Installed $CONFIG"
  exit 0
fi

payload="$(mktemp)"
merged="$(mktemp)"
trap 'rm -f "$payload" "$merged"' EXIT

# Everything after the fragment's [tui] header is the payload to splice in.
awk 'found; $0 == "[tui]" { found = 1 }' "$FRAGMENT" > "$payload"

awk -v payload="$payload" '
  /^\[/ { in_tui = ($0 == "[tui]"); skip = 0 }
  in_tui && skip { if (/^[[:space:]]*\]/) skip = 0; next }
  in_tui && /^[[:space:]]*status_line[[:space:]]*=/ { if ($0 !~ /\]/) skip = 1; next }
  { print }
  $0 == "[tui]" && !inserted {
    while ((getline line < payload) > 0) print line
    inserted = 1
  }
  END {
    if (!inserted) {
      print ""
      print "[tui]"
      while ((getline line < payload) > 0) print line
    }
  }
' "$CONFIG" > "$merged"

# Text surgery on a file another program owns earns a parse check.
if command -v python3 > /dev/null 2>&1; then
  if ! python3 -c 'import sys, tomllib; tomllib.load(open(sys.argv[1], "rb"))' "$merged" 2> /dev/null; then
    echo "ERROR: merged config.toml does not parse; $CONFIG left untouched" >&2
    exit 1
  fi
fi

if cmp -s "$merged" "$CONFIG"; then
  exit 0
fi
cp "$CONFIG" "$CONFIG.bak"
echo "Backed up existing $CONFIG to $CONFIG.bak"
cp "$merged" "$CONFIG"
echo "Installed codex statusline into $CONFIG"
