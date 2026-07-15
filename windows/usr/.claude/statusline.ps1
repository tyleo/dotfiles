# Claude Code status line (Windows PowerShell)
# Format: {db-icon} {context} {context-percent}% {bulb-icon} {model} {bolt-icon} {effort} {calendar-icon} {7d-usage}% {reset-day} {reset-hh:mm} {timer-icon} {5h-usage}% {reset-hh:mm} {folder-icon} {working-directory} {branch-icon} {branch-name}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

## Config

# Nerd Font glyphs when $true; middle-dot and shade fallbacks when $false
$USE_NERD = $true

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
# Reset code
$RESET = [char]27 + "[0m"

## Icons

if ($USE_NERD) {
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
    # right cap full | U+EE05 (kept for completeness; unused under current spec)
    $ICON_BAR_RIGHT_FULL = [char]0xEE05
} else {
    ### Plain Unicode fallbacks

    # middle dot | U+00B7
    $ICON_DOT = [char]0x00B7
    # context has no icon; every other icon is the dot
    $ICON_DB = ''
    $ICON_BOLT = $ICON_DOT
    $ICON_BULB = $ICON_DOT
    $ICON_CALENDAR = $ICON_DOT
    $ICON_TIMER = $ICON_DOT
    $ICON_FOLDER = $ICON_DOT
    $ICON_BRANCH = $ICON_DOT

    ### Shade progress-bar segments

    # light shade | U+2591
    $ICON_SHADE_LIGHT = [char]0x2591
    # dark shade | U+2593
    $ICON_SHADE_DARK = [char]0x2593
    $ICON_BAR_LEFT_EMPTY = $ICON_SHADE_LIGHT
    $ICON_BAR_CENTER_EMPTY = $ICON_SHADE_LIGHT
    $ICON_BAR_RIGHT_EMPTY = $ICON_SHADE_LIGHT
    $ICON_BAR_LEFT_FULL = $ICON_SHADE_DARK
    $ICON_BAR_CENTER_FULL = $ICON_SHADE_DARK
    $ICON_BAR_RIGHT_FULL = $ICON_SHADE_DARK
}

## Reusable functions

# Wrap text in a color and reset.
function Colorize($color, $text) {
    return "$color$text$RESET"
}

## Segment formatters

# These return empty string when the segment should be hidden

# Context: database icon + 10-char bar + percentage. Arg: used_percentage (may be $null).
function Format-Context($pct) {
    if ($null -eq $pct) { $pct = 0 }
    $pct_int = [int][Math]::Round($pct)
    # 10 cells total (left cap + 8 center + right cap), each = 10%, floor mapping
    # ([int] cast on a double uses banker's rounding, so use Math.Floor for true floor)
    $filled = [Math]::Min(10, [int][Math]::Floor($pct_int / 10))
    $left_cap = if ($filled -ge 1) { $ICON_BAR_LEFT_FULL } else { $ICON_BAR_LEFT_EMPTY }
    $right_cap = if ($filled -ge 10) { $ICON_BAR_RIGHT_FULL } else { $ICON_BAR_RIGHT_EMPTY }
    $center_filled = [Math]::Max(0, [Math]::Min(8, $filled - 1))
    $center_empty = 8 - $center_filled
    $bar = [string]$left_cap +
           ([string]$ICON_BAR_CENTER_FULL * $center_filled) +
           ([string]$ICON_BAR_CENTER_EMPTY * $center_empty) +
           [string]$right_cap
    $pct_str = "{0:D2}" -f $pct_int
    $icon_prefix = if ($ICON_DB) { "$ICON_DB " } else { '' }
    return Colorize $RED "$icon_prefix$bar $pct_str%"
}

# Model: lightbulb icon + display name with leading "Claude " and any trailing
# parenthetical suffix (e.g. " (1M context)") stripped. Arg: display_name.
function Format-Model($display_name) {
    if (-not $display_name) { return "" }
    $short_model = $display_name -replace '^Claude ', '' -replace ' \(.*\)$', ''
    return Colorize $ORANGE "$ICON_BULB $short_model"
}

# Effort: bolt + level. Only present when the model exposes reasoning. Arg: effort_level.
function Format-Effort($level) {
    if (-not $level) { return "" }
    return Colorize $YELLOW "$ICON_BOLT $level"
}

# Weekly usage: calendar icon + 7-day usage percent with reset day (RFC 5545
# code) and time, 24-hour clock. Args: weekly_pct weekly_reset_epoch.
function Format-UsageWeekly($w_pct, $w_reset) {
    if ($null -eq $w_pct -or $null -eq $w_reset) { return "" }
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    $w_pct_str = '{0:D2}' -f [int][Math]::Round($w_pct)
    $w_local = [DateTimeOffset]::FromUnixTimeSeconds([long]$w_reset).ToLocalTime()
    $w_day = @('SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA')[[int]$w_local.DayOfWeek]
    $w_time = $w_local.ToString('HH:mm', $inv)
    return Colorize $GREEN "$ICON_CALENDAR $w_pct_str% $w_day $w_time"
}

# Hourly usage: timer icon + 5-hour usage percent with reset time, 24-hour
# clock. Args: hourly_pct hourly_reset_epoch.
function Format-UsageHourly($h_pct, $h_reset) {
    if ($null -eq $h_pct -or $null -eq $h_reset) { return "" }
    $inv = [System.Globalization.CultureInfo]::InvariantCulture
    $h_pct_str = '{0:D2}' -f [int][Math]::Round($h_pct)
    $h_time = [DateTimeOffset]::FromUnixTimeSeconds([long]$h_reset).ToLocalTime().ToString('HH:mm', $inv)
    return Colorize $BLUE "$ICON_TIMER $h_pct_str% $h_time"
}

# Directory: folder icon + cwd, with $HOME collapsed to ~. Arg: cwd.
function Format-Directory($cwd) {
    if (-not $cwd) { return "" }
    $home_dir = $env:USERPROFILE -replace '\\','/'
    $display_cwd = $cwd -replace '\\','/'
    if ($display_cwd.StartsWith($home_dir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $display_dir = '~' + $display_cwd.Substring($home_dir.Length)
    } else {
        $display_dir = $display_cwd
    }
    return Colorize $INDIGO "$ICON_FOLDER $display_dir"
}

# Git: branch icon + branch (or short SHA on detached HEAD), plus posh-git-style
# status counts. One `git status` call covers branch + ahead/behind + file states;
# stash count is read directly from the reflog file. Arg: cwd.
function Format-Git($cwd) {
    if (-not $cwd) { return "" }
    $ErrorActionPreference = 'SilentlyContinue'
    $porcelain = & git -C "$cwd" -c core.fsmonitor= --no-optional-locks status --porcelain=v2 --branch 2>$null
    $ErrorActionPreference = 'Continue'
    if ($LASTEXITCODE -ne 0) { return "" }

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
    if (-not $branch) { return "" }

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
    return Colorize $PURPLE "$ICON_BRANCH $branch$status"
}

## Main: parse JSON once, render segments in order, join with spaces

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
foreach ($seg in @(
    (Format-Context $ctx_pct),
    (Format-Model $model_display),
    (Format-Effort $effort_level),
    (Format-UsageWeekly $weekly_pct $weekly_reset),
    (Format-UsageHourly $hourly_pct $hourly_reset),
    (Format-Directory $cwd),
    (Format-Git $cwd)
)) {
    if ($seg) { $parts += $seg }
}
[Console]::Write(($parts -join ' '))
