# Statusline segment: reasoning effort. Dot-sourced by statusline.ps1.

# nf-fa-bolt | U+F0E7
function Format-EffortIcon { return [char]0xF0E7 }

# Effort: level; ? when the model doesn't expose reasoning. Arg: statusline
# data.
function Format-Effort($data) {
    $level = $data.effort.level
    if (-not $level) { return "?" }
    return $level
}
