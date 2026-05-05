# Claude Code status line (Windows PowerShell)
# Format: {db-icon} {context} {context-percent}% {bolt-icon} {model} {bulb-icon} {effort} {folder-icon} {working-directory} {branch-icon} {branch-name}

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

# Resolve cwd (workspace.current_dir, falling back to .cwd).
function Get-Cwd($data) {
    if ($data.workspace.current_dir) { return $data.workspace.current_dir }
    return $data.cwd
}

## Segment formatters

# These return empty string when the segment should be hidden

# Context: database icon + 10-char bar + percentage
function Format-Context($data) {
    $used_pct = $data.context_window.used_percentage
    if ($null -ne $used_pct) {
        $pct_int = [int][Math]::Round($used_pct)
    } else {
        $pct_int = 0
    }
    # 10 cells total (left cap + 8 center + right cap), each = 10%, floor mapping
    $filled = [Math]::Min(10, [int]($pct_int / 10))
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

# Model: bolt icon + display name (with leading "Claude " stripped)
function Format-Model($data) {
    if (-not $data.model.display_name) { return "" }
    $short_model = $data.model.display_name -replace '^Claude ', ''
    return Colorize $ORANGE "$ICON_BULB $short_model"
}

# Effort: lightbulb + level. Only present when the model exposes reasoning.
function Format-Effort($data) {
    if (-not $data.effort.level) { return "" }
    return Colorize $YELLOW "$ICON_BOLT $($data.effort.level)"
}

# Directory: folder icon + cwd, with $HOME collapsed to ~
function Format-Directory($data) {
    $cwd = Get-Cwd $data
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

# Git: branch icon + branch name (or short SHA on detached HEAD)
function Format-Git($data) {
    $cwd = Get-Cwd $data
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

## Main: read input once, render segments in order, join with spaces

$input_json = [Console]::In.ReadToEnd()
$data       = $input_json | ConvertFrom-Json

$parts = @()
foreach ($fn in @('Format-Context','Format-Model','Format-Effort','Format-Directory','Format-Git')) {
    $seg = & $fn $data
    if ($seg) { $parts += $seg }
}
[Console]::Write(($parts -join ' '))
