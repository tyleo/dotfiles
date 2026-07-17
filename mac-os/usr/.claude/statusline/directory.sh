#!/bin/bash

# Statusline segment: working directory. Sourced by statusline.sh.

# workspace.current_dir, or cwd when unset
format_directory_filter() {
    printf '%s' '
        .workspace.current_dir as $w |
        if $w == null or $w == "" then .cwd // "" else $w end'
}

# nf-fa-folder | U+F07B
format_directory_icon() { printf '\xef\x81\xbb'; }

# Directory: cwd, with $HOME collapsed to ~; ? when missing. Arg: cwd.
format_directory() {
    local cwd="$1" display_dir
    [ -z "$cwd" ] && { printf '?'; return; }
    case "$cwd" in
        "$HOME") display_dir="~" ;;
        "$HOME"/*) display_dir="~${cwd#$HOME}" ;;
        *) display_dir="$cwd" ;;
    esac
    printf '%s' "$display_dir"
}
