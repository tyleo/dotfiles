#!/bin/bash
# Claude Code status line
# Default format: {db-icon} {context} {context-percent}% {bulb-icon} {model} {bolt-icon} {effort} {calendar-icon} {7d-usage}% {reset-day} {reset-hh:mm} {timer-icon} {5h-usage}% {reset-hh:mm} {folder-icon} {working-directory} {branch-icon} {branch-name}
# Segment order, visibility, and colors come from SEGMENTS and SEGMENT_COLORS

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
# 256-color indigo
readonly INDIGO=$'\033[38;5;105m'
# 256-color medium-purple
readonly PURPLE=$'\033[38;5;141m'
# bright-white
readonly WHITE=$'\033[97m'
# Reset code
readonly RESET=$'\033[0m'

## Config

# Nerd Font glyphs when true; middle-dot and shade fallbacks when false
USE_NERD=true
# Segments render in this order; remove entries to hide them
SEGMENTS=(context model effort usage-weekly usage-hourly directory git)
# Colors pair with SEGMENTS by position; extra entries are ignored, missing ones render white
SEGMENT_COLORS=("$RED" "$ORANGE" "$YELLOW" "$GREEN" "$BLUE" "$INDIGO" "$PURPLE")

## Icons

if [ "$USE_NERD" = true ]; then
    ### Nerd Font glyphs

    # nf-fa-database | U+F1C0
    readonly ICON_DB=$(printf '\xef\x87\x80')
    # nf-fa-bolt | U+F0E7
    readonly ICON_BOLT=$(printf '\xef\x83\xa7')
    # nf-md-lightbulb | U+F0335
    readonly ICON_BULB=$(printf '\xf3\xb0\x8c\xb5')
    # nf-md-calendar_week | U+F0A33
    readonly ICON_CALENDAR=$(printf '\xf3\xb0\xa8\xb3')
    # nf-md-timer_sand | U+F051F
    readonly ICON_TIMER=$(printf '\xf3\xb0\x94\x9f')
    # nf-fa-folder | U+F07B
    readonly ICON_FOLDER=$(printf '\xef\x81\xbb')
    # nf-pl-branch | U+E0A0
    readonly ICON_BRANCH=$(printf '\xee\x82\xa0')

    ### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

    # left cap empty | U+EE00
    readonly ICON_BAR_LEFT_EMPTY=$(printf '\xee\xb8\x80')
    # center cell empty | U+EE01
    readonly ICON_BAR_CENTER_EMPTY=$(printf '\xee\xb8\x81')
    # right cap empty | U+EE02
    readonly ICON_BAR_RIGHT_EMPTY=$(printf '\xee\xb8\x82')
    # left cap full | U+EE03
    readonly ICON_BAR_LEFT_FULL=$(printf '\xee\xb8\x83')
    # center cell full | U+EE04
    readonly ICON_BAR_CENTER_FULL=$(printf '\xee\xb8\x84')
    # right cap full | U+EE05 (kept for completeness; unused under current spec)
    readonly ICON_BAR_RIGHT_FULL=$(printf '\xee\xb8\x85')
else
    ### Plain Unicode fallbacks

    # middle dot | U+00B7
    readonly ICON_DOT=$(printf '\xc2\xb7')
    # every icon is the dot
    readonly ICON_DB="$ICON_DOT"
    readonly ICON_BOLT="$ICON_DOT"
    readonly ICON_BULB="$ICON_DOT"
    readonly ICON_CALENDAR="$ICON_DOT"
    readonly ICON_TIMER="$ICON_DOT"
    readonly ICON_FOLDER="$ICON_DOT"
    readonly ICON_BRANCH="$ICON_DOT"

    ### Shade progress-bar segments

    # light shade | U+2591
    readonly ICON_SHADE_LIGHT=$(printf '\xe2\x96\x91')
    # dark shade | U+2593
    readonly ICON_SHADE_DARK=$(printf '\xe2\x96\x93')
    readonly ICON_BAR_LEFT_EMPTY="$ICON_SHADE_LIGHT"
    readonly ICON_BAR_CENTER_EMPTY="$ICON_SHADE_LIGHT"
    readonly ICON_BAR_RIGHT_EMPTY="$ICON_SHADE_LIGHT"
    readonly ICON_BAR_LEFT_FULL="$ICON_SHADE_DARK"
    readonly ICON_BAR_CENTER_FULL="$ICON_SHADE_DARK"
    readonly ICON_BAR_RIGHT_FULL="$ICON_SHADE_DARK"
fi

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

# These return the segment body only; the render loop adds icon and color.
# Formatters never return empty: missing data renders as ? placeholders
# (??% / ??:?? in usage) so segments never pop in or out.

# Context: 10-char bar + percentage; empty bar with ??% when missing.
# Arg: used_percentage (may be empty).
format_context() {
    local pct_int filled center_filled center_empty left_cap right_cap bar pct_str
    if [ -n "$1" ]; then
        pct_int=$(printf '%.0f' "$1")
        pct_str=$(printf '%02d' "$pct_int")
    else
        pct_int=0
        pct_str="??"
    fi
    # 10 cells total (left cap + 8 center + right cap), each = 10%, floor mapping
    filled=$(( pct_int / 10 ))
    [ "$filled" -gt 10 ] && filled=10
    if [ "$filled" -ge 1 ]; then left_cap="$ICON_BAR_LEFT_FULL"; else left_cap="$ICON_BAR_LEFT_EMPTY"; fi
    if [ "$filled" -ge 10 ]; then right_cap="$ICON_BAR_RIGHT_FULL"; else right_cap="$ICON_BAR_RIGHT_EMPTY"; fi
    center_filled=$(( filled - 1 ))
    [ "$center_filled" -lt 0 ] && center_filled=0
    [ "$center_filled" -gt 8 ] && center_filled=8
    center_empty=$(( 8 - center_filled ))
    bar="${left_cap}$(repeat "$ICON_BAR_CENTER_FULL" "$center_filled")$(repeat "$ICON_BAR_CENTER_EMPTY" "$center_empty")${right_cap}"
    printf '%s' "${bar} ${pct_str}%"
}

# Model: display name with leading "Claude " and any trailing parenthetical
# suffix (e.g. " (1M context)") stripped; ? when missing. Arg: display_name.
format_model() {
    local display_name="$1"
    [ -z "$display_name" ] && { printf '?'; return; }
    local short=${display_name#Claude }
    short=${short% (*}
    printf '%s' "$short"
}

# Effort: level; ? when the model doesn't expose reasoning. Arg: effort_level.
format_effort() {
    printf '%s' "${1:-?}"
}

# Weekly usage: 7-day usage percent with reset day (RFC 5545 code) and time,
# 24-hour clock. Rate-limit data is absent until the first API response, so
# missing values render as ?? placeholders instead of hiding the segment.
# Args: weekly_pct weekly_reset_day_time.
format_usage_weekly() {
    local w_pct="$1" w_day_time="$2"
    if [ -n "$w_pct" ]; then w_pct=$(printf '%02.0f' "$w_pct"); else w_pct="??"; fi
    [ -z "$w_day_time" ] && w_day_time="?? ??:??"
    printf '%s' "${w_pct}% ${w_day_time}"
}

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock.
# Rate-limit data is absent until the first API response, so missing values
# render as ?? placeholders instead of hiding the segment.
# Args: hourly_pct hourly_reset_time.
format_usage_hourly() {
    local h_pct="$1" h_time="$2"
    if [ -n "$h_pct" ]; then h_pct=$(printf '%02.0f' "$h_pct"); else h_pct="??"; fi
    [ -z "$h_time" ] && h_time="??:??"
    printf '%s' "${h_pct}% ${h_time}"
}

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

# Git: branch (or short SHA on detached HEAD), plus posh-git-style
# status counts; ? outside a git repo. One `git status` fork covers branch +
# ahead/behind + file states; stash count is read directly from the reflog
# file. Arg: cwd.
format_git() {
    local cwd="$1"
    [ -z "$cwd" ] && { printf '?'; return; }
    local porcelain
    porcelain=$(git -C "$cwd" -c core.fsmonitor= --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || { printf '?'; return; }
    local branch="" oid=""
    local ahead=0 behind=0 conflicted=0 staged=0 renamed=0 deleted=0 modified=0 untracked=0
    while IFS= read -r line; do
        case "$line" in
            "# branch.head "*) branch=${line#"# branch.head "} ;;
            "# branch.oid "*) oid=${line#"# branch.oid "} ;;
            "# branch.ab "*)
                local ab=${line#"# branch.ab "}
                ahead=${ab%% *}; ahead=${ahead#+}
                behind=${ab##* }; behind=${behind#-}
                ;;
            "1 "*)
                local x=${line:2:1} y=${line:3:1}
                case "$x" in [MTADC]) staged=$((staged + 1)) ;; esac
                case "$y" in
                    M|T) modified=$((modified + 1)) ;;
                    D) deleted=$((deleted + 1)) ;;
                esac
                ;;
            "2 "*) renamed=$((renamed + 1)) ;;
            "u "*) conflicted=$((conflicted + 1)) ;;
            "? "*) untracked=$((untracked + 1)) ;;
        esac
    done <<EOF
$porcelain
EOF
    [ "$branch" = "(detached)" ] && branch=${oid:0:7}
    [ -z "$branch" ] && { printf '?'; return; }

    # Stash count from reflog file (no fork). Misses linked-worktree stashes.
    local stashed=0 _line
    if [ -f "$cwd/.git/logs/refs/stash" ]; then
        while IFS= read -r _line; do stashed=$((stashed + 1)); done < "$cwd/.git/logs/refs/stash"
    fi

    local s=""
    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then s="${s}↕ ↑${ahead} ↓${behind} "
    elif [ "$ahead" -gt 0 ]; then s="${s}↑${ahead} "
    elif [ "$behind" -gt 0 ]; then s="${s}↓${behind} "
    fi
    [ "$conflicted" -gt 0 ] && s="${s}✖${conflicted} "
    [ "$stashed" -gt 0 ] && s="${s}\$${stashed} "
    [ "$staged" -gt 0 ] && s="${s}+${staged} "
    [ "$renamed" -gt 0 ] && s="${s}»${renamed} "
    [ "$deleted" -gt 0 ] && s="${s}-${deleted} "
    [ "$modified" -gt 0 ] && s="${s}!${modified} "
    [ "$untracked" -gt 0 ] && s="${s}?${untracked} "

    local status=""
    [ -n "$s" ] && status=" [${s% }]"
    printf '%s' "${branch}${status}"
}

## Main: parse JSON in one jq call, render configured segments in order, join with spaces

input=$(cat)

# Extract every field we need in a single jq call (5 forks down to 1).
# Each value lands on its own line; we feed the output through a heredoc
# so consecutive empty lines don't get collapsed (which IFS=$'\t' would do)
# and so we don't depend on bash-only process substitution (settings.json
# may invoke this via /bin/sh, which disables `<( )` in POSIX mode).
jq_out=$(echo "$input" | jq -r '
    .context_window.used_percentage // "",
    .model.display_name // "",
    .effort.level // "",
    .rate_limits.five_hour.used_percentage // "",
    (.rate_limits.five_hour.resets_at // "" |
        if . == "" then "" else strflocaltime("%H:%M") end),
    .rate_limits.seven_day.used_percentage // "",
    (.rate_limits.seven_day.resets_at // "" |
        if . == "" then "" else
            ["MO", "TU", "WE", "TH", "FR", "SA", "SU"][(strflocaltime("%u") | tonumber) - 1]
            + " " + strflocaltime("%H:%M")
        end),
    .workspace.current_dir // "",
    .cwd // ""
')
{
    read -r ctx_pct
    read -r model_display
    read -r effort_level
    read -r hourly_pct
    read -r hourly_reset_time
    read -r weekly_pct
    read -r weekly_reset_day_time
    read -r workspace_dir
    read -r fallback_cwd
} <<EOF
$jq_out
EOF
cwd="${workspace_dir:-$fallback_cwd}"

out="" idx=0
for name in "${SEGMENTS[@]}"; do
    case "$name" in
        context) icon="$ICON_DB" body=$(format_context "$ctx_pct") ;;
        model) icon="$ICON_BULB" body=$(format_model "$model_display") ;;
        effort) icon="$ICON_BOLT" body=$(format_effort "$effort_level") ;;
        usage-weekly) icon="$ICON_CALENDAR" body=$(format_usage_weekly "$weekly_pct" "$weekly_reset_day_time") ;;
        usage-hourly) icon="$ICON_TIMER" body=$(format_usage_hourly "$hourly_pct" "$hourly_reset_time") ;;
        directory) icon="$ICON_FOLDER" body=$(format_directory "$cwd") ;;
        git) icon="$ICON_BRANCH" body=$(format_git "$cwd") ;;
        *) continue ;;
    esac
    color="${SEGMENT_COLORS[$idx]:-$WHITE}"
    idx=$(( idx + 1 ))
    out="${out:+$out }$(colorize "$color" "$icon $body")"
done
echo "$out"
