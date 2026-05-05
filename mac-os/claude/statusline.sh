#!/bin/bash
# Claude Code status line
# Format: {db-icon} {context} {context-percent}% {bulb-icon} {model} {bolt-icon} {effort} {folder-icon} {working-directory} {branch-icon} {branch-name}

## Colors

# 256-color light coral
readonly RED=$'\033[38;5;203m'
# 256-color orange
readonly ORANGE=$'\033[38;5;214m'
# bright-yellow
readonly YELLOW=$'\033[93m'
# bright-green
readonly GREEN=$'\033[92m'
# bright-cyan
readonly BLUE=$'\033[96m'
# Reset code
readonly RESET=$'\033[0m'

## Icons

### Nerd Font glyphs

# nf-fa-database | U+F1C0
readonly ICON_DB=$(printf '\xef\x87\x80')
# nf-fa-bolt | U+F0E7
readonly ICON_BOLT=$(printf '\xef\x83\xa7')
# nf-md-lightbulb | U+F0335
readonly ICON_BULB=$(printf '\xf3\xb0\x8c\xb5')
# nf-fa-folder | U+F07B
readonly ICON_FOLDER=$(printf '\xef\x81\xbb')
# nf-pl-branch | U+E0A0
readonly ICON_BRANCH=$(printf '\xee\x82\xa0')

### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

# left cap empty | U+EE00
readonly ICON_BAR_LEFT_EMPTY=$(printf   '\xee\xb8\x80')
# center cell empty | U+EE01
readonly ICON_BAR_CENTER_EMPTY=$(printf '\xee\xb8\x81')
# right cap empty | U+EE02
readonly ICON_BAR_RIGHT_EMPTY=$(printf  '\xee\xb8\x82')
# left cap full | U+EE03
readonly ICON_BAR_LEFT_FULL=$(printf    '\xee\xb8\x83')
# center cell full | U+EE04
readonly ICON_BAR_CENTER_FULL=$(printf  '\xee\xb8\x84')
# right cap full | U+EE05 (kept for completeness; unused under current spec)
readonly ICON_BAR_RIGHT_FULL=$(printf   '\xee\xb8\x85')

## Reusable functions

# Read a jq path from the cached JSON input. Returns empty string if missing.
json_get() {
    echo "$INPUT" | jq -r "$1 // empty"
}

# Wrap text in a color and reset.
colorize() {
    local color="$1"; shift
    printf '%s%s%s' "$color" "$*" "$RESET"
}

# Repeat a single character N times.
repeat() {
    local char="$1" n="$2" out="" i=0
    while [ "$i" -lt "$n" ]; do out="${out}${char}"; i=$(( i + 1 )); done
    printf '%s' "$out"
}

# Resolve cwd (workspace.current_dir, falling back to .cwd).
get_cwd() {
    local c
    c=$(json_get '.workspace.current_dir')
    [ -z "$c" ] && c=$(json_get '.cwd')
    printf '%s' "$c"
}

## Segment formatters

# These return empty string when the segment should be hidden

# Context: database icon + 10-char bar + percentage
format_context() {
    local used_pct pct_int filled center_filled center_empty left_cap right_cap bar pct_str
    used_pct=$(json_get '.context_window.used_percentage')
    pct_int=$(printf '%.0f' "${used_pct:-0}")
    # 10 cells total (left cap + 8 center + right cap), each = 10%, floor mapping
    filled=$(( pct_int / 10 ))
    [ "$filled" -gt 10 ] && filled=10
    if [ "$filled" -ge 1 ]; then left_cap="$ICON_BAR_LEFT_FULL";  else left_cap="$ICON_BAR_LEFT_EMPTY";  fi
    if [ "$filled" -ge 10 ]; then right_cap="$ICON_BAR_RIGHT_FULL"; else right_cap="$ICON_BAR_RIGHT_EMPTY"; fi
    center_filled=$(( filled - 1 ))
    [ "$center_filled" -lt 0 ] && center_filled=0
    [ "$center_filled" -gt 8 ] && center_filled=8
    center_empty=$(( 8 - center_filled ))
    bar="${left_cap}$(repeat "$ICON_BAR_CENTER_FULL" "$center_filled")$(repeat "$ICON_BAR_CENTER_EMPTY" "$center_empty")${right_cap}"
    pct_str=$(printf '%02d' "$pct_int")
    colorize "$RED" "${ICON_DB} ${bar} ${pct_str}%"
}

# Model: lightbulb icon + display name (with leading "Claude " stripped)
format_model() {
    local model_display short_model
    model_display=$(json_get '.model.display_name')
    [ -z "$model_display" ] && return
    short_model=${model_display#Claude }
    colorize "$ORANGE" "${ICON_BULB} ${short_model}"
}

# Effort: bolt + level. Only present when the model exposes reasoning.
format_effort() {
    local effort_level
    effort_level=$(json_get '.effort.level')
    [ -z "$effort_level" ] && return
    colorize "$YELLOW" "${ICON_BOLT} ${effort_level}"
}

# Directory: folder icon + cwd, with $HOME collapsed to ~
format_directory() {
    local cwd display_dir
    cwd=$(get_cwd)
    [ -z "$cwd" ] && return
    display_dir="${cwd/#$HOME/~}"
    colorize "$GREEN" "${ICON_FOLDER} ${display_dir}"
}

# Git: branch icon + branch name (or short SHA on detached HEAD)
format_git() {
    local cwd branch
    cwd=$(get_cwd)
    [ -z "$cwd" ] && return
    git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir >/dev/null 2>&1 || return
    branch=$(git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return
    colorize "$BLUE" "${ICON_BRANCH} ${branch}"
}

## Main: read input once, render segments in order, join with spaces

INPUT=$(cat)

out=""
for fn in format_context format_model format_effort format_directory format_git; do
    seg=$("$fn")
    [ -z "$seg" ] && continue
    if [ -z "$out" ]; then out="$seg"; else out="$out $seg"; fi
done
echo "$out"
