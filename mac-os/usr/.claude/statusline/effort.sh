#!/bin/bash

# Statusline segment: reasoning effort. Sourced by statusline.sh.

# nf-fa-bolt | U+F0E7
format_effort_icon() { printf '\xef\x83\xa7'; }

# Effort: level; ? when the model doesn't expose reasoning. Arg: statusline
# JSON.
format_effort() {
    local level
    level=$(printf '%s' "$1" | jq -r '.effort.level // ""' 2>/dev/null)
    printf '%s' "${level:-?}"
}
