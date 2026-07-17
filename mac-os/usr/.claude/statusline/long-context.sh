#!/bin/bash

# Statusline segment: context-window bar. Sourced by statusline.sh.

### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

# left cap empty | U+EE00
ICON_BAR_LEFT_EMPTY=$(printf '\xee\xb8\x80')
# center cell empty | U+EE01
ICON_BAR_CENTER_EMPTY=$(printf '\xee\xb8\x81')
# right cap empty | U+EE02
ICON_BAR_RIGHT_EMPTY=$(printf '\xee\xb8\x82')
# left cap full | U+EE03
ICON_BAR_LEFT_FULL=$(printf '\xee\xb8\x83')
# center cell full | U+EE04
ICON_BAR_CENTER_FULL=$(printf '\xee\xb8\x84')
# right cap full | U+EE05; unused, kept for completeness
ICON_BAR_RIGHT_FULL=$(printf '\xee\xb8\x85')

### Shade progress-bar segments

# light shade | U+2591
ICON_SHADE_LIGHT=$(printf '\xe2\x96\x91')
# dark shade | U+2593
ICON_SHADE_DARK=$(printf '\xe2\x96\x93')

# Repeat a single character N times.
repeat() {
    local char="$1" n="$2" out="" i=0
    while [ "$i" -lt "$n" ]; do out="${out}${char}"; i=$(( i + 1 )); done
    printf '%s' "$out"
}

# Build the 10-cell context bar (left cap + 8 center + right cap); each cell =
# 10%, floor mapping. Args: pct_int cap_l_empty cell_empty cap_r_empty
# cap_l_full cell_full cap_r_full.
build_bar() {
    local pct_int="$1" cap_l_empty="$2" cell_empty="$3" cap_r_empty="$4"
    local cap_l_full="$5" cell_full="$6" cap_r_full="$7"
    local filled cells_filled cells_empty left_cap right_cap
    filled=$(( pct_int / 10 ))
    [ "$filled" -gt 10 ] && filled=10
    if [ "$filled" -ge 1 ]; then left_cap="$cap_l_full"; else left_cap="$cap_l_empty"; fi
    if [ "$filled" -ge 10 ]; then right_cap="$cap_r_full"; else right_cap="$cap_r_empty"; fi
    cells_filled=$(( filled - 1 ))
    [ "$cells_filled" -lt 0 ] && cells_filled=0
    [ "$cells_filled" -gt 8 ] && cells_filled=8
    cells_empty=$(( 8 - cells_filled ))
    printf '%s%s%s%s' "$left_cap" "$(repeat "$cell_full" "$cells_filled")" "$(repeat "$cell_empty" "$cells_empty")" "$right_cap"
}

# Pull the used percentage out of the statusline JSON as a whole number;
# missing means a fresh session, so 0.
context_pct() {
    local pct
    pct=$(printf '%s' "$1" | jq -r '.context_window.used_percentage // 0' 2>/dev/null)
    printf '%.0f' "${pct:-0}"
}

# nf-fa-database | U+F1C0
format_context_long_icon() { printf '\xef\x87\x80'; }

# Context (long): Nerd Font bar + percentage. Arg: statusline JSON.
format_context_long() {
    local pct_int
    pct_int=$(context_pct "$1")
    printf '%s %02d%%' "$(build_bar "$pct_int" "$ICON_BAR_LEFT_EMPTY" "$ICON_BAR_CENTER_EMPTY" "$ICON_BAR_RIGHT_EMPTY" "$ICON_BAR_LEFT_FULL" "$ICON_BAR_CENTER_FULL" "$ICON_BAR_RIGHT_FULL")" "$pct_int"
}

# nf-fa-database | U+F1C0
format_context_long_shaded_icon() { printf '\xef\x87\x80'; }

# Context (long, shaded): shade-block bar + percentage for fonts without the
# Nerd bar glyphs. Arg: statusline JSON.
format_context_long_shaded() {
    local pct_int
    pct_int=$(context_pct "$1")
    printf '%s %02d%%' "$(build_bar "$pct_int" "$ICON_SHADE_LIGHT" "$ICON_SHADE_LIGHT" "$ICON_SHADE_LIGHT" "$ICON_SHADE_DARK" "$ICON_SHADE_DARK" "$ICON_SHADE_DARK")" "$pct_int"
}
