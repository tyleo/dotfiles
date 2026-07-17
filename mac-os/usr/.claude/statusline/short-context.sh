#!/bin/bash

# Statusline segment: compact context percentage. Sourced by statusline.sh.

format_context_short_filter() { printf '%s' '.context_window.used_percentage // ""'; }

# nf-fa-database | U+F1C0
format_context_short_icon() { printf '\xef\x87\x80'; }

# Context (short): percentage only; missing means a fresh session, so 00%.
# Arg: used_percentage.
format_context_short() {
    printf '%02.0f%%' "${1:-0}"
}
