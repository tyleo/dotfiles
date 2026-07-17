#!/bin/bash

# Statusline segment: working directory. Sourced by statusline.sh.

# nf-fa-folder | U+F07B
format_directory_icon() { printf '\xef\x81\xbb'; }

# Directory: workspace.current_dir (cwd when unset), with $HOME collapsed to
# ~; ? when missing. Arg: statusline JSON.
format_directory() {
    local cwd display_dir
    cwd=$(printf '%s' "$1" | jq -r '
        .workspace.current_dir as $w |
        if $w == null or $w == "" then .cwd // "" else $w end' 2>/dev/null)
    [ -z "$cwd" ] && { printf '?'; return; }
    case "$cwd" in
        "$HOME") display_dir="~" ;;
        "$HOME"/*) display_dir="~${cwd#$HOME}" ;;
        *) display_dir="$cwd" ;;
    esac
    printf '%s' "$display_dir"
}
