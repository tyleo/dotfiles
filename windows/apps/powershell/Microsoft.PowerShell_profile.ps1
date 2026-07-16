Import-Module posh-git

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

$gitconfig = "C:\users\tyleo\.gitconfig"

function cdg() {
    cd "C:\git"
}

function clean-script-assemblies() {
    $path = get-git-root-path
    $path = Join-Path $path "\Library\ScriptAssemblies"
    Remove-Item $path -Recurse
}

# Kills all Unity processes.
function kill-unity() {
    taskkill /f /im Unity.exe /t
}

# Saves a new guid to the clipboard.
function nuid() {
    [System.Guid]::NewGuid().Guid | Set-Clipboard
}

# Opens VSCode at the root of the git project.
function open-git-root-code() {
    $path = get-git-root-path
    code $path
}

# Opens Windows explorer at the root of the git project.
function open-git-root-explorer() {
    $path = get-git-root-path
    explorer $path
}

# Opens Unity at the root of the git project.
function open-git-root-unity() {
    $path = get-git-root-path
    unity -projectPath $path
}

# Opens the PowerShell profile in VSCode.
function open-profile-code() {
    code $profile
}

# This doesn't actually work but is good for remembering the command :P
function reload-profile() {
    .$profile
}

# Switches the Claude Code statusline preset (e.g. set-claude mobile).
function set-claude($preset) {
    $settings_file = Join-Path $HOME ".claude/statusline-settings.json"
    $state_file = Join-Path $HOME ".claude/statusline-state.json"

    if (-not $preset) {
        Write-Output "usage: set-claude <preset>"
        return
    }

    try {
        $presets = (Get-Content -Raw -LiteralPath $settings_file -ErrorAction Stop | ConvertFrom-Json).presets
    } catch {
        Write-Output "❌ Failed to read $settings_file"
        return
    }
    if (-not $presets.$preset) {
        Write-Output "❌ Unknown preset '$preset' (available: $(($presets.PSObject.Properties.Name | Sort-Object) -join ', '))"
        return
    }

    @{ preset = $preset } | ConvertTo-Json | Set-Content -LiteralPath $state_file
    Write-Output "✅ Claude statusline preset set to $preset"
}

# . "C:\Users\tyleo\.config\powershell\tyt-completions.ps1"
