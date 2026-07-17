# Statusline segment: compact context percentage. Dot-sourced by
# statusline.ps1.

# nf-fa-database | U+F1C0
function Format-ContextShortIcon { return [char]0xF1C0 }

# Context (short): percentage only; missing means a fresh session, so 00%.
# Arg: statusline data.
function Format-ContextShort($data) {
    $pct = $data.context_window.used_percentage
    $pct_int = if ($null -ne $pct) { [int][Math]::Round($pct) } else { 0 }
    $pct_str = "{0:D2}" -f $pct_int
    return "$pct_str%"
}
