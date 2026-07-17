#!/bin/bash

# Statusline segment: compact context percentage. Sourced by statusline.sh.

# nf-fa-database | U+F1C0
format_context_short_icon() { printf '\xef\x87\x80'; }

# Context (short): percentage only; missing means a fresh session, so 00%.
# Arg: statusline JSON.
format_context_short() {
    local pct
    pct=$(printf '%s' "$1" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
    printf '%02.0f%%' "${pct:-0}"
}
