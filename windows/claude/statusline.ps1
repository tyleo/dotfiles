# Claude Code status line (Windows PowerShell)
# Format: CCCCCCCCCC ##%  {bolt} Model Name [@ effort] | ~/git/repo   branch-name

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$input_json = [Console]::In.ReadToEnd()
$data = $input_json | ConvertFrom-Json

$cwd = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }

# ANSI colors
$YELLOW = [char]27 + "[93m"
$ORANGE = [char]27 + "[38;5;214m"
$GREEN  = [char]27 + "[92m"
$BLUE   = [char]27 + "[96m"
$RESET  = [char]27 + "[0m"

# Context bar
$used_pct = $data.context_window.used_percentage
if ($null -ne $used_pct) {
    $pct_int    = [int][Math]::Round($used_pct)
    $bar_filled = [int]($pct_int / 10)
    $bar_empty  = 10 - $bar_filled
    $bar        = ([string][char]0x2593) * $bar_filled + ([string][char]0x2591) * $bar_empty
    $context_part = ("${YELLOW}${bar} {0:D2}%${RESET}" -f $pct_int)
} else {
    $bar = ([string][char]0x2591) * 10
    $context_part = "${YELLOW}${bar} 00%${RESET}"
}

# Model name: strip leading "Claude " (e.g. "Sonnet 4.6", "Opus 4.7")
$model_part = ""
if ($data.model.display_name) {
    $short_model = $data.model.display_name -replace '^Claude ', ''
    $effort_str  = if ($data.effort.level) { " @ $($data.effort.level)" } else { "" }
    $bolt_icon   = [char]0xF0E7
    $model_part  = " ${ORANGE}${bolt_icon} ${short_model}${effort_str}${RESET}"
}

# Directory - replace home prefix with ~
$home_dir    = $env:USERPROFILE -replace '\\','/'
$display_cwd = $cwd -replace '\\','/'
if ($display_cwd.StartsWith($home_dir, [System.StringComparison]::OrdinalIgnoreCase)) {
    $display_dir = '~' + $display_cwd.Substring($home_dir.Length)
} else {
    $display_dir = $display_cwd
}

# Git branch (skip optional locks to avoid contention)
$branch_part = ""
$ErrorActionPreference = 'SilentlyContinue'
$null = & git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir 2>&1
$ErrorActionPreference = 'Continue'
if ($LASTEXITCODE -eq 0) {
    $branch = (& git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>&1)
    if ($LASTEXITCODE -ne 0 -or -not $branch) {
        $branch = (& git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>&1)
    }
    if ($LASTEXITCODE -eq 0 -and $branch) {
        $branch_icon = [char]0xE0A0
        $branch_part = " ${BLUE}${branch_icon} ${branch}${RESET}"
    }
}

[Console]::Write("${context_part}${model_part} | ${GREEN}${display_dir}${RESET}${branch_part}")
