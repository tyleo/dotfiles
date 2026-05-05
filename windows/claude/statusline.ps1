# Claude Code status line (Windows PowerShell)
# Format: {db-icon} {context} {context-percent}% {bulb-icon} {model} {bolt-icon} {effort} {folder-icon} {working-directory} {branch-icon} {branch-name}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

## Colors

# 256-color light coral
$RED    = [char]27 + "[38;5;203m"
# 256-color orange
$ORANGE = [char]27 + "[38;5;214m"
# bright-yellow
$YELLOW = [char]27 + "[93m"
# bright-green
$GREEN  = [char]27 + "[92m"
# bright-cyan
$BLUE   = [char]27 + "[96m"
# 256-color medium-purple
$PURPLE = [char]27 + "[38;5;141m"
# Reset code
$RESET  = [char]27 + "[0m"

## Icons

### Nerd Font glyphs

# nf-fa-database | U+F1C0
$ICON_DB     = [char]0xF1C0
# nf-fa-bolt | U+F0E7
$ICON_BOLT   = [char]0xF0E7
# nf-md-lightbulb | U+F0335
$ICON_BULB   = [char]::ConvertFromUtf32(0xF0335)
# nf-fa-folder | U+F07B
$ICON_FOLDER = [char]0xF07B
# nf-pl-branch | U+E0A0
$ICON_BRANCH = [char]0xE0A0

### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

# left cap empty | U+EE00
$ICON_BAR_LEFT_EMPTY   = [char]0xEE00
# center cell empty | U+EE01
$ICON_BAR_CENTER_EMPTY = [char]0xEE01
# right cap empty | U+EE02
$ICON_BAR_RIGHT_EMPTY  = [char]0xEE02
# left cap full | U+EE03
$ICON_BAR_LEFT_FULL    = [char]0xEE03
# center cell full | U+EE04
$ICON_BAR_CENTER_FULL  = [char]0xEE04
# right cap full | U+EE05 (kept for completeness; unused under current spec)
$ICON_BAR_RIGHT_FULL   = [char]0xEE05

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
    $left_cap  = if ($filled -ge 1)  { $ICON_BAR_LEFT_FULL }  else { $ICON_BAR_LEFT_EMPTY }
    $right_cap = if ($filled -ge 10) { $ICON_BAR_RIGHT_FULL } else { $ICON_BAR_RIGHT_EMPTY }
    $center_filled = [Math]::Max(0, [Math]::Min(8, $filled - 1))
    $center_empty  = 8 - $center_filled
    $bar = [string]$left_cap +
           ([string]$ICON_BAR_CENTER_FULL  * $center_filled) +
           ([string]$ICON_BAR_CENTER_EMPTY * $center_empty)  +
           [string]$right_cap
    $pct_str = "{0:D2}" -f $pct_int
    return Colorize $RED "$ICON_DB $bar $pct_str%"
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

# Directory: folder icon + cwd, with $HOME collapsed to ~. Arg: cwd.
function Format-Directory($cwd) {
    if (-not $cwd) { return "" }
    $home_dir    = $env:USERPROFILE -replace '\\','/'
    $display_cwd = $cwd -replace '\\','/'
    if ($display_cwd.StartsWith($home_dir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $display_dir = '~' + $display_cwd.Substring($home_dir.Length)
    } else {
        $display_dir = $display_cwd
    }
    return Colorize $GREEN "$ICON_FOLDER $display_dir"
}

# Git: branch icon + branch name (or short SHA on detached HEAD). Arg: cwd.
function Format-Git($cwd) {
    if (-not $cwd) { return "" }
    $ErrorActionPreference = 'SilentlyContinue'
    $null = & git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir 2>&1
    $ErrorActionPreference = 'Continue'
    if ($LASTEXITCODE -ne 0) { return "" }
    $branch = (& git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not $branch) {
        $branch = (& git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>&1)
    }
    if ($LASTEXITCODE -ne 0 -or -not $branch) { return "" }
    return Colorize $BLUE "$ICON_BRANCH $branch"
}

## Main: parse JSON once, render segments in order, join with spaces

$input_json = [Console]::In.ReadToEnd()
$data       = $input_json | ConvertFrom-Json

# Extract every field we need once. Missing fields surface as $null.
$ctx_pct       = $data.context_window.used_percentage
$model_display = $data.model.display_name
$effort_level  = $data.effort.level
$cwd           = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }

$parts = @()
foreach ($seg in @(
    (Format-Context   $ctx_pct),
    (Format-Model     $model_display),
    (Format-Effort    $effort_level),
    (Format-Directory $cwd),
    (Format-Git       $cwd)
)) {
    if ($seg) { $parts += $seg }
}
[Console]::Write(($parts -join ' '))
