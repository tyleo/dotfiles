#!/bin/bash

# Statusline segment: reasoning effort. Sourced by statusline.sh.

format_effort_filter() { printf '%s' '.effort.level // ""'; }

# nf-fa-bolt | U+F0E7
format_effort_icon() { printf '\xef\x83\xa7'; }

# Effort: level; ? when the model doesn't expose reasoning. Arg: effort_level.
format_effort() {
    printf '%s' "${1:-?}"
}
