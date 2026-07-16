# Claude Code status line (Windows PowerShell)
# Presets come from statusline-settings.json; statusline-state.json selects
# the active preset (desktop when missing). Per preset:
#   iconStyle: icons (Nerd Font) | dots | dots-no-prefix (first icon hidden)
#   iconColor: one color name for every icon; omit to match segment colors
#   segments: long-context | long-context-shaded | short-context | model |
#     effort | usage-weekly | usage-hourly | directory | git | git-no-status
#   colors: pair with segments by position; missing entries render white

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

## Colors

# 256-color light coral
$RED = [char]27 + "[38;5;203m"
# 256-color orange
$ORANGE = [char]27 + "[38;5;214m"
# bright-yellow
$YELLOW = [char]27 + "[93m"
# bright-green
$GREEN = [char]27 + "[92m"
# bright-cyan
$BLUE = [char]27 + "[96m"
# 256-color indigo
$INDIGO = [char]27 + "[38;5;105m"
# 256-color medium-purple
$PURPLE = [char]27 + "[38;5;141m"
# 256-color gray
$GRAY = [char]27 + "[38;5;245m"
# bright-white
$WHITE = [char]27 + "[97m"
$RESET = [char]27 + "[0m"

## Config

$SETTINGS_FILE = Join-Path $HOME ".claude/statusline-settings.json"
$STATE_FILE = Join-Path $HOME ".claude/statusline-state.json"

# The state file exists so shell commands can retheme running sessions
$preset = "desktop"
try {
    $state = Get-Content -Raw -LiteralPath $STATE_FILE -ErrorAction Stop | ConvertFrom-Json
    if ($state.preset) { $preset = $state.preset }
} catch {}

# Unknown presets fall back to desktop
$preset_cfg = $null
try {
    $settings = Get-Content -Raw -LiteralPath $SETTINGS_FILE -ErrorAction Stop | ConvertFrom-Json
    $preset_cfg = if ($settings.presets.$preset) { $settings.presets.$preset } else { $settings.presets.desktop }
} catch {}

# Hardcoded desktop fallback so a missing or invalid settings file never
# breaks the line
if ($preset_cfg -and $preset_cfg.segments) {
    $ICON_STYLE = if ($preset_cfg.iconStyle) { $preset_cfg.iconStyle } else { 'icons' }
    $ICON_COLOR_NAME = if ($preset_cfg.iconColor) { $preset_cfg.iconColor } else { '' }
    $SEGMENTS = @($preset_cfg.segments)
    $SEGMENT_COLORS = @($preset_cfg.colors)
} else {
    $ICON_STYLE = 'icons'
    $ICON_COLOR_NAME = ''
    $SEGMENTS = @('long-context', 'model', 'effort', 'usage-weekly', 'usage-hourly', 'directory', 'git')
    $SEGMENT_COLORS = @('red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'purple')
}

## Icons

if ($ICON_STYLE -eq 'icons') {
    ### Nerd Font glyphs

    # nf-fa-database | U+F1C0
    $ICON_DB = [char]0xF1C0
    # nf-fa-bolt | U+F0E7
    $ICON_BOLT = [char]0xF0E7
    # nf-md-lightbulb | U+F0335
    $ICON_BULB = [char]::ConvertFromUtf32(0xF0335)
    # nf-md-calendar_week | U+F0A33
    $ICON_CALENDAR = [char]::ConvertFromUtf32(0xF0A33)
    # nf-md-timer_sand | U+F051F
    $ICON_TIMER = [char]::ConvertFromUtf32(0xF051F)
    # nf-fa-folder | U+F07B
    $ICON_FOLDER = [char]0xF07B
    # nf-pl-branch | U+E0A0
    $ICON_BRANCH = [char]0xE0A0
} else {
    ### Middle-dot fallback for the dots and dots-no-prefix styles

    # middle dot | U+00B7
    $ICON_DOT = [char]0x00B7
    # every icon is the dot
    $ICON_DB = $ICON_DOT
    $ICON_BOLT = $ICON_DOT
    $ICON_BULB = $ICON_DOT
    $ICON_CALENDAR = $ICON_DOT
    $ICON_TIMER = $ICON_DOT
    $ICON_FOLDER = $ICON_DOT
    $ICON_BRANCH = $ICON_DOT
}

### Progress-bar glyphs; both sets stay defined because the context segment
### variant picks the bar style, not the icon style

### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

# left cap empty | U+EE00
$ICON_BAR_LEFT_EMPTY = [char]0xEE00
# center cell empty | U+EE01
$ICON_BAR_CENTER_EMPTY = [char]0xEE01
# right cap empty | U+EE02
$ICON_BAR_RIGHT_EMPTY = [char]0xEE02
# left cap full | U+EE03
$ICON_BAR_LEFT_FULL = [char]0xEE03
# center cell full | U+EE04
$ICON_BAR_CENTER_FULL = [char]0xEE04
# right cap full | U+EE05; unused, kept for completeness
$ICON_BAR_RIGHT_FULL = [char]0xEE05

### Shade progress-bar segments

# light shade | U+2591
$ICON_SHADE_LIGHT = [char]0x2591
# dark shade | U+2593
$ICON_SHADE_DARK = [char]0x2593

## Reusable functions

# Wrap text in a color and reset.
function Colorize($color, $text) {
    return "$color$text$RESET"
}

# Map a color name to its escape code; unknown or missing names render white.
function Resolve-Color($name) {
    switch ($name) {
        'blue' { return $BLUE }
        'gray' { return $GRAY }
        'green' { return $GREEN }
        'indigo' { return $INDIGO }
        'orange' { return $ORANGE }
        'purple' { return $PURPLE }
        'red' { return $RED }
        'white' { return $WHITE }
        'yellow' { return $YELLOW }
        default { return $WHITE }
    }
}

## Segment formatters

# These return the segment body only; the render loop adds icon and color.
# Formatters never return empty, so segments never pop in or out.

# Build the 10-cell context bar (left cap + 8 center + right cap); each cell =
# 10%, floor mapping. Args: pct_int, then the empty and full glyphs for the
# left cap, center cells, and right cap.
function Build-Bar($pct_int, $cap_l_empty, $cell_empty, $cap_r_empty, $cap_l_full, $cell_full, $cap_r_full) {
    # [int] cast on a double uses banker's rounding, so use Math.Floor for a true floor
    $filled = [Math]::Min(10, [int][Math]::Floor($pct_int / 10))
    $left_cap = if ($filled -ge 1) { $cap_l_full } else { $cap_l_empty }
    $right_cap = if ($filled -ge 10) { $cap_r_full } else { $cap_r_empty }
    $cells_filled = [Math]::Max(0, [Math]::Min(8, $filled - 1))
    $cells_empty = 8 - $cells_filled
    return [string]$left_cap +
           ([string]$cell_full * $cells_filled) +
           ([string]$cell_empty * $cells_empty) +
           [string]$right_cap
}

# Context (long): Nerd Font bar + percentage; missing means a fresh session,
# so 00%. Arg: used_percentage (may be $null).
function Format-ContextLong($pct) {
    $pct_int = if ($null -ne $pct) { [int][Math]::Round($pct) } else { 0 }
    $pct_str = "{0:D2}" -f $pct_int
    $bar = Build-Bar $pct_int $ICON_BAR_LEFT_EMPTY $ICON_BAR_CENTER_EMPTY $ICON_BAR_RIGHT_EMPTY $ICON_BAR_LEFT_FULL $ICON_BAR_CENTER_FULL $ICON_BAR_RIGHT_FULL
    return "$bar $pct_str%"
}

# Context (long, shaded): shade-block bar + percentage for fonts without the
# Nerd bar glyphs. Arg: used_percentage (may be $null).
function Format-ContextLongShaded($pct) {
    $pct_int = if ($null -ne $pct) { [int][Math]::Round($pct) } else { 0 }
    $pct_str = "{0:D2}" -f $pct_int
    $bar = Build-Bar $pct_int $ICON_SHADE_LIGHT $ICON_SHADE_LIGHT $ICON_SHADE_LIGHT $ICON_SHADE_DARK $ICON_SHADE_DARK $ICON_SHADE_DARK
    return "$bar $pct_str%"
}

# Context (short): percentage only. Arg: used_percentage (may be $null).
function Format-ContextShort($pct) {
    $pct_int = if ($null -ne $pct) { [int][Math]::Round($pct) } else { 0 }
    $pct_str = "{0:D2}" -f $pct_int
    return "$pct_str%"
}

# Model: display name with leading "Claude " and any trailing parenthetical
# suffix (e.g. " (1M context)") stripped; ? when missing. Arg: display_name.
function Format-Model($display_name) {
    if (-not $display_name) { return "?" }
    $short_model = $display_name -replace '^Claude ', '' -replace ' \(.*\)$', ''
    return $short_model
}

# Effort: level; ? when the model doesn't expose reasoning. Arg: effort_level.
function Format-Effort($level) {
    if (-not $level) { return "?" }
    return $level
}

# Weekly usage: 7-day usage percent with reset day (RFC 5545 code) and time,
# 24-hour clock; ?? placeholders until the first API response delivers
# rate-limit data. Args: weekly_pct weekly_reset_epoch.
function Format-UsageWeekly($w_pct, $w_reset) {
    $w_pct_str = if ($null -ne $w_pct) { '{0:D2}' -f [int][Math]::Round($w_pct) } else { '??' }
    if ($null -ne $w_reset) {
        $inv = [System.Globalization.CultureInfo]::InvariantCulture
        $w_local = [DateTimeOffset]::FromUnixTimeSeconds([long]$w_reset).ToLocalTime()
        $w_day = @('SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA')[[int]$w_local.DayOfWeek]
        $w_time = $w_local.ToString('HH:mm', $inv)
    } else {
        $w_day = '??'
        $w_time = '??:??'
    }
    return "$w_pct_str% $w_day $w_time"
}

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock;
# ?? placeholders until the first API response delivers rate-limit data.
# Args: hourly_pct hourly_reset_epoch.
function Format-UsageHourly($h_pct, $h_reset) {
    $h_pct_str = if ($null -ne $h_pct) { '{0:D2}' -f [int][Math]::Round($h_pct) } else { '??' }
    $h_time = if ($null -ne $h_reset) {
        $inv = [System.Globalization.CultureInfo]::InvariantCulture
        [DateTimeOffset]::FromUnixTimeSeconds([long]$h_reset).ToLocalTime().ToString('HH:mm', $inv)
    } else { '??:??' }
    return "$h_pct_str% $h_time"
}

# Directory: cwd, with $HOME collapsed to ~; ? when missing. Arg: cwd.
function Format-Directory($cwd) {
    if (-not $cwd) { return "?" }
    $home_dir = $env:USERPROFILE -replace '\\','/'
    $display_cwd = $cwd -replace '\\','/'
    if ($display_cwd.StartsWith($home_dir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $display_dir = '~' + $display_cwd.Substring($home_dir.Length)
    } else {
        $display_dir = $display_cwd
    }
    return $display_dir
}

# Git: branch (or short SHA on detached HEAD), plus posh-git-style
# status counts; ? outside a git repo. One `git status` call covers branch +
# ahead/behind + file states; stash count is read directly from the reflog
# file. Arg: cwd.
function Format-Git($cwd) {
    if (-not $cwd) { return "?" }
    $ErrorActionPreference = 'SilentlyContinue'
    $porcelain = & git -C "$cwd" -c core.fsmonitor= --no-optional-locks status --porcelain=v2 --branch 2>$null
    $ErrorActionPreference = 'Continue'
    if ($LASTEXITCODE -ne 0) { return "?" }

    $branch = ""; $oid = ""
    $ahead = 0; $behind = 0
    $conflicted = 0; $staged = 0; $renamed = 0; $deleted = 0; $modified = 0; $untracked = 0
    foreach ($line in $porcelain) {
        if ($line.StartsWith('# branch.head ')) { $branch = $line.Substring(14) }
        elseif ($line.StartsWith('# branch.oid ')) { $oid = $line.Substring(13) }
        elseif ($line -match '^# branch\.ab \+(\d+) -(\d+)') {
            $ahead = [int]$matches[1]
            $behind = [int]$matches[2]
        }
        elseif ($line.StartsWith('1 ')) {
            $x = $line[2]; $y = $line[3]
            if ('MTADC'.Contains([string]$x)) { $staged++ }
            switch ([string]$y) {
                'M' { $modified++ }
                'T' { $modified++ }
                'D' { $deleted++ }
            }
        }
        elseif ($line.StartsWith('2 ')) { $renamed++ }
        elseif ($line.StartsWith('u ')) { $conflicted++ }
        elseif ($line.StartsWith('? ')) { $untracked++ }
    }
    if ($branch -eq '(detached)') { $branch = $oid.Substring(0, 7) }
    if (-not $branch) { return "?" }

    # Stash count from reflog file (no git call). Misses linked-worktree stashes.
    $stashLog = Join-Path $cwd '.git/logs/refs/stash'
    $stashed = if (Test-Path -LiteralPath $stashLog) {
        @(Get-Content -LiteralPath $stashLog).Count
    } else { 0 }

    $s = ""
    if ($ahead -gt 0 -and $behind -gt 0) { $s += "↕ ↑$ahead ↓$behind " }
    elseif ($ahead -gt 0) { $s += "↑$ahead " }
    elseif ($behind -gt 0) { $s += "↓$behind " }
    if ($conflicted -gt 0) { $s += "✖$conflicted " }
    if ($stashed -gt 0) { $s += "`$$stashed " }
    if ($staged -gt 0) { $s += "+$staged " }
    if ($renamed -gt 0) { $s += "»$renamed " }
    if ($deleted -gt 0) { $s += "-$deleted " }
    if ($modified -gt 0) { $s += "!$modified " }
    if ($untracked -gt 0) { $s += "?$untracked " }

    $status = if ($s) { " [" + $s.TrimEnd() + "]" } else { "" }
    return "$branch$status"
}

# Git (no status): branch only, short SHA on detached HEAD; ? outside a git
# repo. symbolic-ref also names unborn branches, which rev-parse cannot.
# Arg: cwd.
function Format-GitNoStatus($cwd) {
    if (-not $cwd) { return "?" }
    $ErrorActionPreference = 'SilentlyContinue'
    $branch = & git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>$null
    if (-not $branch) { $branch = & git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>$null }
    $ErrorActionPreference = 'Continue'
    if (-not $branch) { return "?" }
    return "$branch"
}

## Main

$input_json = [Console]::In.ReadToEnd()
$data = $input_json | ConvertFrom-Json

# Extract every field we need once. Missing fields surface as $null.
$ctx_pct = $data.context_window.used_percentage
$model_display = $data.model.display_name
$effort_level = $data.effort.level
$hourly_pct = $data.rate_limits.five_hour.used_percentage
$hourly_reset = $data.rate_limits.five_hour.resets_at
$weekly_pct = $data.rate_limits.seven_day.used_percentage
$weekly_reset = $data.rate_limits.seven_day.resets_at
$cwd = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }

$parts = @()
$idx = 0
foreach ($name in $SEGMENTS) {
    $icon = $null
    $body = ''
    switch ($name) {
        'long-context' { $icon = $ICON_DB; $body = Format-ContextLong $ctx_pct }
        'long-context-shaded' { $icon = $ICON_DB; $body = Format-ContextLongShaded $ctx_pct }
        'short-context' { $icon = $ICON_DB; $body = Format-ContextShort $ctx_pct }
        'model' { $icon = $ICON_BULB; $body = Format-Model $model_display }
        'effort' { $icon = $ICON_BOLT; $body = Format-Effort $effort_level }
        'usage-weekly' { $icon = $ICON_CALENDAR; $body = Format-UsageWeekly $weekly_pct $weekly_reset }
        'usage-hourly' { $icon = $ICON_TIMER; $body = Format-UsageHourly $hourly_pct $hourly_reset }
        'directory' { $icon = $ICON_FOLDER; $body = Format-Directory $cwd }
        'git' { $icon = $ICON_BRANCH; $body = Format-Git $cwd }
        'git-no-status' { $icon = $ICON_BRANCH; $body = Format-GitNoStatus $cwd }
    }
    if ($null -eq $icon) { continue }
    $color = Resolve-Color $SEGMENT_COLORS[$idx]
    # dots-no-prefix hides the first icon; iconColor recolors icons only
    if ($idx -eq 0 -and $ICON_STYLE -eq 'dots-no-prefix') {
        $segment = Colorize $color $body
    } elseif ($ICON_COLOR_NAME) {
        $segment = (Colorize (Resolve-Color $ICON_COLOR_NAME) $icon) + ' ' + (Colorize $color $body)
    } else {
        $segment = Colorize $color "$icon $body"
    }
    $idx++
    $parts += $segment
}
[Console]::Write(($parts -join ' '))
