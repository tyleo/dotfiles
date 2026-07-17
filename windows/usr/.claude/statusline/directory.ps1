# Statusline segment: working directory. Dot-sourced by statusline.ps1.

# nf-fa-folder | U+F07B
function Format-DirectoryIcon { return [char]0xF07B }

# Directory: workspace.current_dir (cwd when unset), with the user profile
# collapsed to ~; ? when missing. Arg: statusline data.
function Format-Directory($data) {
    $cwd = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { $data.cwd }
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
