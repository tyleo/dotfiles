#!/bin/bash

# Statusline segment: model name. Sourced by statusline.sh.

# nf-md-lightbulb | U+F0335
format_model_icon() { printf '\xf3\xb0\x8c\xb5'; }

# Model: display name with leading "Claude " and any trailing parenthetical
# suffix (e.g. " (1M context)") stripped; ? when missing. Arg: statusline
# JSON.
format_model() {
    local display_name
    display_name=$(printf '%s' "$1" | jq -r '.model.display_name // ""' 2>/dev/null)
    [ -z "$display_name" ] && { printf '?'; return; }
    local short=${display_name#Claude }
    short=${short% (*}
    printf '%s' "$short"
}
