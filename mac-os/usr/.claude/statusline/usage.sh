#!/bin/bash

# Statusline segment: rate-limit usage. Sourced by statusline.sh.

format_usage_weekly_filter() {
    printf '%s' '
        .rate_limits.seven_day.used_percentage // "",
        (.rate_limits.seven_day.resets_at // "" |
            if . == "" then "" else
                ["MO", "TU", "WE", "TH", "FR", "SA", "SU"][(strflocaltime("%u") | tonumber) - 1]
                + " " + strflocaltime("%H:%M")
            end)'
}

# nf-md-calendar_week | U+F0A33
format_usage_weekly_icon() { printf '\xf3\xb0\xa8\xb3'; }

# Weekly usage: 7-day usage percent with reset day (RFC 5545 code) and time,
# 24-hour clock; ?? placeholders until the first API response delivers
# rate-limit data. Args: weekly_pct weekly_reset_day_time.
format_usage_weekly() {
    local w_pct="$1" w_day_time="$2"
    if [ -n "$w_pct" ]; then w_pct=$(printf '%02.0f' "$w_pct"); else w_pct="??"; fi
    [ -z "$w_day_time" ] && w_day_time="?? ??:??"
    printf '%s' "${w_pct}% ${w_day_time}"
}

format_usage_hourly_filter() {
    printf '%s' '
        .rate_limits.five_hour.used_percentage // "",
        (.rate_limits.five_hour.resets_at // "" |
            if . == "" then "" else strflocaltime("%H:%M") end)'
}

# nf-md-timer_sand | U+F051F
format_usage_hourly_icon() { printf '\xf3\xb0\x94\x9f'; }

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock;
# ?? placeholders until the first API response delivers rate-limit data.
# Args: hourly_pct hourly_reset_time.
format_usage_hourly() {
    local h_pct="$1" h_time="$2"
    if [ -n "$h_pct" ]; then h_pct=$(printf '%02.0f' "$h_pct"); else h_pct="??"; fi
    [ -z "$h_time" ] && h_time="??:??"
    printf '%s' "${h_pct}% ${h_time}"
}
