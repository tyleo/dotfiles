#!/bin/bash
# Claude Code status line
# statuslineconfig.json declares the palette, segment imports, and profiles;
# its profile key selects the active one. No config file (or no matching
# profile) means no profile, so nothing renders. Config:
#   profile: name of the active profile; runtime state that set_claude
#     rewrites so shell commands can retheme running sessions
#   colors: color name -> ANSI escape, the palette profiles reference by name
#   segments: segment name -> { file, import }; sourcing statusline/<file>
#     defines <import>, which formats the statusline JSON in $1 into the
#     segment body, and <import>_icon, which prints the default icon
#   profiles.<name>.segments: segment names rendered in order
#   profiles.<name>.colors: color names cycled across segments; omit to
#     render everything white
#   profiles.<name>.icons: icons cycled across segments; omit to use each
#     segment's default icon; an empty entry hides that icon
#   profiles.<name>.iconColors: color names cycled across icons; omit to
#     match each icon to its segment color

## Config

readonly ROOT="$HOME"
readonly CONFIG_FILE="$ROOT/.claude/statuslineconfig.json"
readonly SEGMENTS_DIR="$ROOT/.claude/statusline"

# bright-white fallback for unknown or missing color names
readonly WHITE=$'\033[97m'
readonly RESET=$'\033[0m'

## Reusable functions

# Wrap text in a color and reset.
colorize() {
    local color="$1"; shift
    printf '%s%s%s' "$color" "$*" "$RESET"
}

# Read N lines from stdin into the named array (bash 3.2: no namerefs).
read_array() {
    local name="$1" n="$2" i=0 line
    eval "$name=()"
    while [ "$i" -lt "$n" ]; do
        IFS= read -r line
        eval "$name[\$i]=\$line"
        i=$(( i + 1 ))
    done
}

# Map a color name to its escape code; unknown or missing names render white.
resolve_color() {
    local i=0
    while [ "$i" -lt "${#COLOR_NAMES[@]}" ]; do
        if [ "${COLOR_NAMES[$i]}" = "$1" ]; then
            printf '%s' "${COLOR_CODES[$i]}"
            return
        fi
        i=$(( i + 1 ))
    done
    printf '%s' "$WHITE"
}

## Profile

# One jq call emits every list as a count line followed by one entry per
# line, so entries survive being empty (mobile hides its first icon with "")
cfg=$(jq -r '
    (.profile // "") as $profile |
    (.profiles[$profile] // {}) as $p |
    ($p.segments // []) as $segs |
    ($segs | length),
    (($p.colors // []) | length),
    (($p.colors // [])[]),
    (($p.icons // []) | length),
    (($p.icons // [])[]),
    (($p.iconColors // []) | length),
    (($p.iconColors // [])[]),
    ((.colors // {}) | length),
    ((.colors // {}) | to_entries[] | .key, .value),
    ($segs[] as $s | ((.segments[$s] // {}) | (.file // ""), (.import // "")))
' "$CONFIG_FILE" 2>/dev/null) || exit 0

{
    IFS= read -r seg_count
    IFS= read -r color_count
    read_array PROFILE_COLORS "${color_count:-0}"
    IFS= read -r icon_count
    read_array PROFILE_ICONS "${icon_count:-0}"
    IFS= read -r icon_color_count
    read_array PROFILE_ICON_COLORS "${icon_color_count:-0}"
    IFS= read -r map_count
    COLOR_NAMES=()
    COLOR_CODES=()
    i=0
    while [ "$i" -lt "${map_count:-0}" ]; do
        IFS= read -r name
        IFS= read -r code
        COLOR_NAMES[i]=$name
        COLOR_CODES[i]=$code
        i=$(( i + 1 ))
    done
    SEG_FILES=()
    SEG_IMPORTS=()
    i=0
    while [ "$i" -lt "${seg_count:-0}" ]; do
        IFS= read -r file
        IFS= read -r import
        SEG_FILES[i]=$file
        SEG_IMPORTS[i]=$import
        i=$(( i + 1 ))
    done
} <<EOF
$cfg
EOF

# A profile without segments is no profile either
[ "${seg_count:-0}" -gt 0 ] || exit 0

## Main

input=$(cat)

out="" sourced=" " rendered=0 idx=0
while [ "$idx" -lt "$seg_count" ]; do
    file="${SEG_FILES[$idx]}"
    import="${SEG_IMPORTS[$idx]}"
    idx=$(( idx + 1 ))
    [ -n "$file" ] && [ -n "$import" ] || continue

    # Segment files source once even when two imports share one file
    case "$sourced" in
        *" $file "*) ;;
        *)
            sourced="${sourced}${file} "
            [ -f "$SEGMENTS_DIR/$file" ] && . "$SEGMENTS_DIR/$file"
            ;;
    esac
    command -v "$import" >/dev/null 2>&1 || continue
    body=$("$import" "$input")

    if [ "$icon_count" -gt 0 ]; then
        icon="${PROFILE_ICONS[$(( rendered % icon_count ))]}"
    elif command -v "${import}_icon" >/dev/null 2>&1; then
        icon=$("${import}_icon")
    else
        icon=""
    fi

    color_name=""
    [ "$color_count" -gt 0 ] && color_name="${PROFILE_COLORS[$(( rendered % color_count ))]}"
    color=$(resolve_color "$color_name")

    if [ -z "$icon" ]; then
        segment=$(colorize "$color" "$body")
    else
        icon_color="$color"
        [ "$icon_color_count" -gt 0 ] && icon_color=$(resolve_color "${PROFILE_ICON_COLORS[$(( rendered % icon_color_count ))]}")
        # One escape pair when the colors match keeps the output compact
        if [ "$icon_color" = "$color" ]; then
            segment=$(colorize "$color" "$icon $body")
        else
            segment="$(colorize "$icon_color" "$icon") $(colorize "$color" "$body")"
        fi
    fi
    rendered=$(( rendered + 1 ))
    out="${out:+$out }${segment}"
done
echo "$out"
