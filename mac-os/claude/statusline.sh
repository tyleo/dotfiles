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
# 256-color medium-purple
readonly PURPLE=$'\033[38;5;141m'
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

## Segment formatters

# These return empty string when the segment should be hidden

# Context: database icon + 10-char bar + percentage. Arg: used_percentage (may be empty).
format_context() {
    local pct_int filled center_filled center_empty left_cap right_cap bar pct_str
    pct_int=$(printf '%.0f' "${1:-0}")
    # 10 cells total (left cap + 8 center + right cap), each = 10%, floor mapping
    filled=$(( pct_int / 10 ))
    [ "$filled" -gt 10 ] && filled=10
    if [ "$filled" -ge 1 ];  then left_cap="$ICON_BAR_LEFT_FULL";   else left_cap="$ICON_BAR_LEFT_EMPTY";   fi
    if [ "$filled" -ge 10 ]; then right_cap="$ICON_BAR_RIGHT_FULL"; else right_cap="$ICON_BAR_RIGHT_EMPTY"; fi
    center_filled=$(( filled - 1 ))
    [ "$center_filled" -lt 0 ] && center_filled=0
    [ "$center_filled" -gt 8 ] && center_filled=8
    center_empty=$(( 8 - center_filled ))
    bar="${left_cap}$(repeat "$ICON_BAR_CENTER_FULL" "$center_filled")$(repeat "$ICON_BAR_CENTER_EMPTY" "$center_empty")${right_cap}"
    pct_str=$(printf '%02d' "$pct_int")
    colorize "$RED" "${ICON_DB} ${bar} ${pct_str}%"
}

# Model: lightbulb icon + display name (with leading "Claude " stripped). Arg: display_name.
format_model() {
    local display_name="$1"
    [ -z "$display_name" ] && return
    colorize "$ORANGE" "${ICON_BULB} ${display_name#Claude }"
}

# Effort: bolt + level. Only present when the model exposes reasoning. Arg: effort_level.
format_effort() {
    [ -z "$1" ] && return
    colorize "$YELLOW" "${ICON_BOLT} $1"
}

# Directory: folder icon + cwd, with $HOME collapsed to ~. Arg: cwd.
format_directory() {
    local cwd="$1" display_dir
    [ -z "$cwd" ] && return
    case "$cwd" in
        "$HOME")    display_dir="~" ;;
        "$HOME"/*)  display_dir="~${cwd#$HOME}" ;;
        *)          display_dir="$cwd" ;;
    esac
    colorize "$GREEN" "${ICON_FOLDER} ${display_dir}"
}

# Git: branch icon + branch name (or short SHA on detached HEAD). Arg: cwd.
format_git() {
    local cwd="$1" branch
    [ -z "$cwd" ] && return
    git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir >/dev/null 2>&1 || return
    branch=$(git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && return
    colorize "$BLUE" "${ICON_BRANCH} ${branch}"
}

## Main: parse JSON in one jq call, render segments in order, join with spaces

input=$(cat)

# Extract every field we need in a single jq call (5 forks down to 1).
# Each value lands on its own line; we feed the output through a heredoc
# so consecutive empty lines don't get collapsed (which IFS=$'\t' would do)
# and so we don't depend on bash-only process substitution (settings.json
# may invoke this via /bin/sh, which disables `<( )` in POSIX mode).
jq_out=$(echo "$input" | jq -r '
    .context_window.used_percentage // "",
    .model.display_name             // "",
    .effort.level                   // "",
    .workspace.current_dir          // "",
    .cwd                            // ""
')
{
    read -r ctx_pct
    read -r model_display
    read -r effort_level
    read -r workspace_dir
    read -r fallback_cwd
} <<EOF
$jq_out
EOF
cwd="${workspace_dir:-$fallback_cwd}"

out=""
for seg in "$(format_context   "$ctx_pct")" \
           "$(format_model     "$model_display")" \
           "$(format_effort    "$effort_level")" \
           "$(format_directory "$cwd")" \
           "$(format_git       "$cwd")"; do
    [ -z "$seg" ] && continue
    out="${out:+$out }$seg"
done
echo "$out"
