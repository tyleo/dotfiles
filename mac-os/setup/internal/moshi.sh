#!/usr/bin/env bash

# Hook Claude Code and Codex up to Moshi, the iPhone app that relays their
# approvals and notifications. `moshi-hook install` owns the hooks, plugin, and
# skill it writes, and it leaves every other key alone, so it is safe to rerun.
# Pairing takes a token from the phone, so this step only reminds us to pair.

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/lib.sh"

# `moshi-hook` comes from the Brewfile, so brew must be on PATH.
ensure_brew

# Call it by brew's opt path, since every hook it writes runs the path it was
# called by.
moshi_hook="$(brew --prefix moshi-hook)/bin/moshi-hook"

"$moshi_hook" install --target claude,codex

if [ "$("$moshi_hook" status --json | jq -r .paired)" != "true" ]; then
  echo "Moshi is not paired. Get a token in the Moshi iPhone app (Settings -> Integrations), then run:"
  echo "  moshi-hook pair --token <token>"
fi
