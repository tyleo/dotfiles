# Statusline segment: context-window bar. Dot-sourced by statusline.ps1.

### Nerd Font progress-bar segments (Fira Code, U+EE00-U+EE05)

# left cap empty | U+EE00
$ICON_BAR_LEFT_EMPTY = [char]0xEE00
# center cell empty | U+EE01
$ICON_BAR_CENTER_EMPTY = [char]0xEE01
# right cap empty | U+EE02
$ICON_BAR_RIGHT_EMPTY = [char]0xEE02
# left cap full | U+EE03
$ICON_BAR_LEFT_FULL = [char]0xEE03
# center cell full | U+EE04
$ICON_BAR_CENTER_FULL = [char]0xEE04
# right cap full | U+EE05; unused, kept for completeness
$ICON_BAR_RIGHT_FULL = [char]0xEE05

### Shade progress-bar segments

# light shade | U+2591
$ICON_SHADE_LIGHT = [char]0x2591
# dark shade | U+2593
$ICON_SHADE_DARK = [char]0x2593

# Build the 10-cell context bar (left cap + 8 center + right cap); each cell =
# 10%, floor mapping. Args: pct_int, then the empty and full glyphs for the
# left cap, center cells, and right cap.
function Build-Bar($pct_int, $cap_l_empty, $cell_empty, $cap_r_empty, $cap_l_full, $cell_full, $cap_r_full) {
    # [int] cast on a double uses banker's rounding, so use Math.Floor for a true floor
    $filled = [Math]::Min(10, [int][Math]::Floor($pct_int / 10))
    $left_cap = if ($filled -ge 1) { $cap_l_full } else { $cap_l_empty }
    $right_cap = if ($filled -ge 10) { $cap_r_full } else { $cap_r_empty }
    $cells_filled = [Math]::Max(0, [Math]::Min(8, $filled - 1))
    $cells_empty = 8 - $cells_filled
    return [string]$left_cap +
           ([string]$cell_full * $cells_filled) +
           ([string]$cell_empty * $cells_empty) +
           [string]$right_cap
}

# Pull the used percentage out of the statusline data as a whole number;
# missing means a fresh session, so 0.
function Get-ContextPct($data) {
    $pct = $data.context_window.used_percentage
    if ($null -ne $pct) { return [int][Math]::Round($pct) }
    return 0
}

# nf-fa-database | U+F1C0
function Format-ContextLongIcon { return [char]0xF1C0 }

# Context (long): Nerd Font bar + percentage. Arg: statusline data.
function Format-ContextLong($data) {
    $pct_int = Get-ContextPct $data
    $pct_str = "{0:D2}" -f $pct_int
    $bar = Build-Bar $pct_int $ICON_BAR_LEFT_EMPTY $ICON_BAR_CENTER_EMPTY $ICON_BAR_RIGHT_EMPTY $ICON_BAR_LEFT_FULL $ICON_BAR_CENTER_FULL $ICON_BAR_RIGHT_FULL
    return "$bar $pct_str%"
}

# nf-fa-database | U+F1C0
function Format-ContextLongShadedIcon { return [char]0xF1C0 }

# Context (long, shaded): shade-block bar + percentage for fonts without the
# Nerd bar glyphs. Arg: statusline data.
function Format-ContextLongShaded($data) {
    $pct_int = Get-ContextPct $data
    $pct_str = "{0:D2}" -f $pct_int
    $bar = Build-Bar $pct_int $ICON_SHADE_LIGHT $ICON_SHADE_LIGHT $ICON_SHADE_LIGHT $ICON_SHADE_DARK $ICON_SHADE_DARK $ICON_SHADE_DARK
    return "$bar $pct_str%"
}
