# Claude Code status line (Windows PowerShell)
# statuslineconfig.json declares the palette, segment imports, and profiles;
# its profile key selects the active one. No config file (or no matching
# profile) means no profile, so nothing renders. Config:
#   profile: name of the active profile; runtime state that set-claude
#     rewrites so shell commands can retheme running sessions
#   colors: color name -> ANSI escape, the palette profiles reference by name
#   segments: segment name -> { file, import }; dot-sourcing
#     statusline/<file> defines <import>, which formats the parsed statusline
#     JSON into the segment body, and <import>Icon, which returns the default
#     icon
#   profiles.<name>.segments: segment names rendered in order
#   profiles.<name>.colors: color names cycled across segments; omit to
#     render everything white
#   profiles.<name>.icons: icons cycled across segments; omit to use each
#     segment's default icon; an empty entry hides that icon
#   profiles.<name>.iconColors: color names cycled across icons; omit to
#     match each icon to its segment color

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

## Config

$ROOT = $HOME
$CONFIG_FILE = Join-Path $ROOT ".claude/statuslineconfig.json"
$SEGMENTS_DIR = Join-Path $ROOT ".claude/statusline"

# bright-white fallback for unknown or missing color names
$WHITE = [char]27 + "[97m"
$RESET = [char]27 + "[0m"

## Reusable functions

# Wrap text in a color and reset.
function Colorize($color, $text) {
    return "$color$text$RESET"
}

# Map a color name to its escape code; unknown or missing names render white.
function Resolve-Color($name) {
    if ($name -and $COLOR_MAP -and $COLOR_MAP.PSObject.Properties[$name]) {
        return $COLOR_MAP.$name
    }
    return $WHITE
}

## Profile

$settings = $null
try {
    $settings = Get-Content -Raw -LiteralPath $CONFIG_FILE -ErrorAction Stop | ConvertFrom-Json
} catch {}
$profile_name = if ($settings) { $settings.profile } else { $null }
if (-not $profile_name) { exit 0 }
$profile_cfg = $settings.profiles.$profile_name

# A profile without segments is no profile either
if (-not ($profile_cfg -and $profile_cfg.segments)) { exit 0 }
$SEGMENTS = @($profile_cfg.segments)
# Outer @( ) rewraps the one-element arrays that `if` output unrolls; the
# $null guards keep a missing key from becoming @($null)
$PROFILE_COLORS = @(if ($null -ne $profile_cfg.colors) { $profile_cfg.colors })
$PROFILE_ICONS = @(if ($null -ne $profile_cfg.icons) { $profile_cfg.icons })
$PROFILE_ICON_COLORS = @(if ($null -ne $profile_cfg.iconColors) { $profile_cfg.iconColors })
$COLOR_MAP = $settings.colors

## Main

$input_json = [Console]::In.ReadToEnd()
$data = $null
try { $data = $input_json | ConvertFrom-Json } catch {}

# Segment files dot-source once even when two imports share one file
$sourced = @{}
$parts = @()
$rendered = 0
foreach ($name in $SEGMENTS) {
    $seg = if ($settings.segments) { $settings.segments.$name } else { $null }
    if (-not ($seg -and $seg.file -and $seg.import)) { continue }
    if (-not $sourced.ContainsKey($seg.file)) {
        $sourced[$seg.file] = $true
        $seg_path = Join-Path $SEGMENTS_DIR $seg.file
        if (Test-Path -LiteralPath $seg_path) { . $seg_path }
    }
    $import = $seg.import
    if (-not (Get-Command $import -CommandType Function -ErrorAction SilentlyContinue)) { continue }
    $body = & $import $data

    $icon = if ($PROFILE_ICONS.Count -gt 0) {
        $PROFILE_ICONS[$rendered % $PROFILE_ICONS.Count]
    } elseif (Get-Command "$($import)Icon" -CommandType Function -ErrorAction SilentlyContinue) {
        & "$($import)Icon"
    } else { '' }

    $color_name = if ($PROFILE_COLORS.Count -gt 0) { $PROFILE_COLORS[$rendered % $PROFILE_COLORS.Count] } else { '' }
    $color = Resolve-Color $color_name

    if (-not $icon) {
        $segment = Colorize $color $body
    } else {
        $icon_color = if ($PROFILE_ICON_COLORS.Count -gt 0) {
            Resolve-Color $PROFILE_ICON_COLORS[$rendered % $PROFILE_ICON_COLORS.Count]
        } else { $color }
        # One escape pair when the colors match keeps the output compact
        if ($icon_color -eq $color) {
            $segment = Colorize $color "$icon $body"
        } else {
            $segment = (Colorize $icon_color $icon) + ' ' + (Colorize $color $body)
        }
    }
    $rendered++
    $parts += $segment
}
[Console]::Write(($parts -join ' '))
