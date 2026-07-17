# Statusline segment: rate-limit usage. Dot-sourced by statusline.ps1.

# nf-md-calendar_week | U+F0A33
function Format-UsageWeeklyIcon { return [char]::ConvertFromUtf32(0xF0A33) }

# Weekly usage: 7-day usage percent with reset day (RFC 5545 code) and time,
# 24-hour clock; ?? placeholders until the first API response delivers
# rate-limit data. Arg: statusline data.
function Format-UsageWeekly($data) {
    $w_pct = $data.rate_limits.seven_day.used_percentage
    $w_reset = $data.rate_limits.seven_day.resets_at
    $w_pct_str = if ($null -ne $w_pct) { '{0:D2}' -f [int][Math]::Round($w_pct) } else { '??' }
    if ($null -ne $w_reset) {
        $inv = [System.Globalization.CultureInfo]::InvariantCulture
        $w_local = [DateTimeOffset]::FromUnixTimeSeconds([long]$w_reset).ToLocalTime()
        $w_day = @('SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA')[[int]$w_local.DayOfWeek]
        $w_time = $w_local.ToString('HH:mm', $inv)
    } else {
        $w_day = '??'
        $w_time = '??:??'
    }
    return "$w_pct_str% $w_day $w_time"
}

# nf-md-timer_sand | U+F051F
function Format-UsageHourlyIcon { return [char]::ConvertFromUtf32(0xF051F) }

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock;
# ?? placeholders until the first API response delivers rate-limit data.
# Arg: statusline data.
function Format-UsageHourly($data) {
    $h_pct = $data.rate_limits.five_hour.used_percentage
    $h_reset = $data.rate_limits.five_hour.resets_at
    $h_pct_str = if ($null -ne $h_pct) { '{0:D2}' -f [int][Math]::Round($h_pct) } else { '??' }
    $h_time = if ($null -ne $h_reset) {
        $inv = [System.Globalization.CultureInfo]::InvariantCulture
        [DateTimeOffset]::FromUnixTimeSeconds([long]$h_reset).ToLocalTime().ToString('HH:mm', $inv)
    } else { '??:??' }
    return "$h_pct_str% $h_time"
}
