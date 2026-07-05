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

# . "C:\Users\tyleo\.config\powershell\tyt-completions.ps1"
