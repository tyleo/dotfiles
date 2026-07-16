#!/bin/bash
# Claude Code status line
# Presets come from statusline-settings.json; statusline-state.json selects
# the active preset (desktop when missing). Per preset:
#   iconStyle: icons (Nerd Font) | dots | dots-no-prefix (first icon hidden)
#   iconColor: one color name for every icon; omit to match segment colors
#   segments: long-context | long-context-shaded | short-context | model |
#     effort | usage-weekly | usage-hourly | directory | git | git-no-status
#   colors: pair with segments by position; missing entries render white

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
# 256-color gray
readonly GRAY=$'\033[38;5;245m'
# bright-white
readonly WHITE=$'\033[97m'
readonly RESET=$'\033[0m'

## Config

readonly SETTINGS_FILE="$HOME/.claude/statusline-settings.json"
readonly STATE_FILE="$HOME/.claude/statusline-state.json"

# The state file exists so shell commands can retheme running sessions
preset=$(jq -r '.preset // empty' "$STATE_FILE" 2>/dev/null)
[ -z "$preset" ] && preset=desktop

# One jq call emits iconStyle, iconColor, segments, and colors on four lines;
# unknown presets fall back to desktop
preset_cfg=$(jq -r --arg preset "$preset" '
    (.presets[$preset] // .presets.desktop // {}) |
    .iconStyle // "icons",
    .iconColor // "",
    (.segments // [] | join(" ")),
    (.colors // [] | join(" "))
' "$SETTINGS_FILE" 2>/dev/null)
{
    read -r ICON_STYLE
    read -r ICON_COLOR_NAME
    read -r segments_line
    read -r colors_line
} <<EOF
$preset_cfg
EOF

# Hardcoded desktop fallback so a missing or invalid settings file never
# breaks the line
if [ -z "$segments_line" ]; then
    ICON_STYLE=icons
    ICON_COLOR_NAME=""
    segments_line="long-context model effort usage-weekly usage-hourly directory git"
    colors_line="red orange yellow green blue indigo purple"
fi
read -ra SEGMENTS <<EOF
$segments_line
EOF
read -ra SEGMENT_COLORS <<EOF
$colors_line
EOF

## Icons

if [ "$ICON_STYLE" = icons ]; then
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
else
    ### Middle-dot fallback for the dots and dots-no-prefix styles

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
fi

### Progress-bar glyphs; both sets stay defined because the context segment
### variant picks the bar style, not the icon style

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
# right cap full | U+EE05; unused, kept for completeness
readonly ICON_BAR_RIGHT_FULL=$(printf '\xee\xb8\x85')

### Shade progress-bar segments

# light shade | U+2591
readonly ICON_SHADE_LIGHT=$(printf '\xe2\x96\x91')
# dark shade | U+2593
readonly ICON_SHADE_DARK=$(printf '\xe2\x96\x93')

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

# Map a color name to its escape code; unknown or missing names render white.
resolve_color() {
    case "$1" in
        blue) printf '%s' "$BLUE" ;;
        gray) printf '%s' "$GRAY" ;;
        green) printf '%s' "$GREEN" ;;
        indigo) printf '%s' "$INDIGO" ;;
        orange) printf '%s' "$ORANGE" ;;
        purple) printf '%s' "$PURPLE" ;;
        red) printf '%s' "$RED" ;;
        white) printf '%s' "$WHITE" ;;
        yellow) printf '%s' "$YELLOW" ;;
        *) printf '%s' "$WHITE" ;;
    esac
}

## Segment formatters

# These return the segment body only; the render loop adds icon and color.
# Formatters never return empty, so segments never pop in or out.

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

# Context (long): Nerd Font bar + percentage; missing means a fresh session,
# so 00%. Arg: used_percentage (may be empty).
format_context_long() {
    local pct_int
    pct_int=$(printf '%.0f' "${1:-0}")
    printf '%s %02d%%' "$(build_bar "$pct_int" "$ICON_BAR_LEFT_EMPTY" "$ICON_BAR_CENTER_EMPTY" "$ICON_BAR_RIGHT_EMPTY" "$ICON_BAR_LEFT_FULL" "$ICON_BAR_CENTER_FULL" "$ICON_BAR_RIGHT_FULL")" "$pct_int"
}

# Context (long, shaded): shade-block bar + percentage for fonts without the
# Nerd bar glyphs. Arg: used_percentage (may be empty).
format_context_long_shaded() {
    local pct_int
    pct_int=$(printf '%.0f' "${1:-0}")
    printf '%s %02d%%' "$(build_bar "$pct_int" "$ICON_SHADE_LIGHT" "$ICON_SHADE_LIGHT" "$ICON_SHADE_LIGHT" "$ICON_SHADE_DARK" "$ICON_SHADE_DARK" "$ICON_SHADE_DARK")" "$pct_int"
}

# Context (short): percentage only. Arg: used_percentage (may be empty).
format_context_short() {
    printf '%02.0f%%' "${1:-0}"
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
# 24-hour clock; ?? placeholders until the first API response delivers
# rate-limit data. Args: weekly_pct weekly_reset_day_time.
format_usage_weekly() {
    local w_pct="$1" w_day_time="$2"
    if [ -n "$w_pct" ]; then w_pct=$(printf '%02.0f' "$w_pct"); else w_pct="??"; fi
    [ -z "$w_day_time" ] && w_day_time="?? ??:??"
    printf '%s' "${w_pct}% ${w_day_time}"
}

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock;
# ?? placeholders until the first API response delivers rate-limit data.
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

# Git (no status): branch only, short SHA on detached HEAD; ? outside a git
# repo. symbolic-ref also names unborn branches, which rev-parse cannot.
# Arg: cwd.
format_git_no_status() {
    local cwd="$1"
    [ -z "$cwd" ] && { printf '?'; return; }
    local branch
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && { printf '?'; return; }
    printf '%s' "$branch"
}

## Main

input=$(cat)

# Extract every field we need in a single jq call.
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
        long-context) icon="$ICON_DB" body=$(format_context_long "$ctx_pct") ;;
        long-context-shaded) icon="$ICON_DB" body=$(format_context_long_shaded "$ctx_pct") ;;
        short-context) icon="$ICON_DB" body=$(format_context_short "$ctx_pct") ;;
        model) icon="$ICON_BULB" body=$(format_model "$model_display") ;;
        effort) icon="$ICON_BOLT" body=$(format_effort "$effort_level") ;;
        usage-weekly) icon="$ICON_CALENDAR" body=$(format_usage_weekly "$weekly_pct" "$weekly_reset_day_time") ;;
        usage-hourly) icon="$ICON_TIMER" body=$(format_usage_hourly "$hourly_pct" "$hourly_reset_time") ;;
        directory) icon="$ICON_FOLDER" body=$(format_directory "$cwd") ;;
        git) icon="$ICON_BRANCH" body=$(format_git "$cwd") ;;
        git-no-status) icon="$ICON_BRANCH" body=$(format_git_no_status "$cwd") ;;
        *) continue ;;
    esac
    color=$(resolve_color "${SEGMENT_COLORS[$idx]}")
    # dots-no-prefix hides the first icon; iconColor recolors icons only
    if [ "$idx" -eq 0 ] && [ "$ICON_STYLE" = dots-no-prefix ]; then
        segment=$(colorize "$color" "$body")
    elif [ -n "$ICON_COLOR_NAME" ]; then
        segment="$(colorize "$(resolve_color "$ICON_COLOR_NAME")" "$icon") $(colorize "$color" "$body")"
    else
        segment=$(colorize "$color" "$icon $body")
    fi
    idx=$(( idx + 1 ))
    out="${out:+$out }${segment}"
done
echo "$out"
