#!/bin/bash

# Statusline segment: model name. Sourced by statusline.sh.

format_model_filter() { printf '%s' '.model.display_name // ""'; }

# nf-md-lightbulb | U+F0335
format_model_icon() { printf '\xf3\xb0\x8c\xb5'; }

# Model: display name with leading "Claude " and any trailing parenthetical
# suffix (e.g. " (1M context)") stripped; ? when missing. Arg: display_name.
format_model() {
    local display_name="$1"
    [ -z "$display_name" ] && { printf '?'; return; }
    local short=${display_name#Claude }
    short=${short% (*}
    printf '%s' "$short"
}
