Import-Module posh-git

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

$gitconfig = "C:\users\tyleo\.gitconfig"

function alc_log() {
    $Env:RUST_LOG = "gfx_backend_vulkan"
}

function cdg() {
    cd "C:\git"
}

function git_clip() {
    git log --pretty=format:'%b' -n 1 | clip
}

function nuid() {
    [System.Guid]::NewGuid().Guid | Set-Clipboard
}
