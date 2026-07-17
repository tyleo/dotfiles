# Statusline segment: model name. Dot-sourced by statusline.ps1.

# nf-md-lightbulb | U+F0335
function Format-ModelIcon { return [char]::ConvertFromUtf32(0xF0335) }

# Model: display name with leading "Claude " and any trailing parenthetical
# suffix (e.g. " (1M context)") stripped; ? when missing. Arg: statusline
# data.
function Format-Model($data) {
    $display_name = $data.model.display_name
    if (-not $display_name) { return "?" }
    $short_model = $display_name -replace '^Claude ', '' -replace ' \(.*\)$', ''
    return $short_model
}
