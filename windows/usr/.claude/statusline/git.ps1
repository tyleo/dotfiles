# Statusline segment: git branch and status. Dot-sourced by statusline.ps1.

# nf-pl-branch | U+E0A0
function Format-GitIcon { return [char]0xE0A0 }

# Git: branch (or short SHA on detached HEAD), plus posh-git-style
# status counts; ? outside a git repo. One `git status` call covers branch +
# ahead/behind + file states; stash count is read directly from the reflog
# file. Arg: statusline data.
function Format-Git($data) {
    $cwd = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }
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

# nf-pl-branch | U+E0A0
function Format-GitNoStatusIcon { return [char]0xE0A0 }

# Git (no status): branch only, short SHA on detached HEAD; ? outside a git
# repo. symbolic-ref also names unborn branches, which rev-parse cannot.
# Arg: statusline data.
function Format-GitNoStatus($data) {
    $cwd = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }
    if (-not $cwd) { return "?" }
    $ErrorActionPreference = 'SilentlyContinue'
    $branch = & git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>$null
    if (-not $branch) { $branch = & git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>$null }
    $ErrorActionPreference = 'Continue'
    if (-not $branch) { return "?" }
    return "$branch"
}
