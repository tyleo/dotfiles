$query = ($input | Out-String | ConvertFrom-Json).query ?? ''
$dir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { "." }
Set-Location $dir
rg --files --follow . 2>$null | ForEach-Object { $_ -replace '\\','/' } | fzf --filter $query | Select-Object -First 15
