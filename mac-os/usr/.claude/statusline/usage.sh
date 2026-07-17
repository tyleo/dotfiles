#!/bin/bash

# Statusline segment: rate-limit usage. Sourced by statusline.sh.

# nf-md-calendar_week | U+F0A33
format_usage_weekly_icon() { printf '\xf3\xb0\xa8\xb3'; }

# Weekly usage: 7-day usage percent with reset day (RFC 5545 code) and time,
# 24-hour clock; ?? placeholders until the first API response delivers
# rate-limit data. Arg: statusline JSON.
format_usage_weekly() {
    local jq_out pct day_time
    jq_out=$(printf '%s' "$1" | jq -r '
        .rate_limits.seven_day.used_percentage // "",
        (.rate_limits.seven_day.resets_at // "" |
            if . == "" then "" else
                ["MO", "TU", "WE", "TH", "FR", "SA", "SU"][(strflocaltime("%u") | tonumber) - 1]
                + " " + strflocaltime("%H:%M")
            end)' 2>/dev/null)
    {
        IFS= read -r pct
        IFS= read -r day_time
    } <<EOF
$jq_out
EOF
    if [ -n "$pct" ]; then pct=$(printf '%02.0f' "$pct"); else pct="??"; fi
    [ -z "$day_time" ] && day_time="?? ??:??"
    printf '%s' "${pct}% ${day_time}"
}

# nf-md-timer_sand | U+F051F
format_usage_hourly_icon() { printf '\xf3\xb0\x94\x9f'; }

# Hourly usage: 5-hour usage percent with reset time, 24-hour clock;
# ?? placeholders until the first API response delivers rate-limit data.
# Arg: statusline JSON.
format_usage_hourly() {
    local jq_out pct reset_time
    jq_out=$(printf '%s' "$1" | jq -r '
        .rate_limits.five_hour.used_percentage // "",
        (.rate_limits.five_hour.resets_at // "" |
            if . == "" then "" else strflocaltime("%H:%M") end)' 2>/dev/null)
    {
        IFS= read -r pct
        IFS= read -r reset_time
    } <<EOF
$jq_out
EOF
    if [ -n "$pct" ]; then pct=$(printf '%02.0f' "$pct"); else pct="??"; fi
    [ -z "$reset_time" ] && reset_time="??:??"
    printf '%s' "${pct}% ${reset_time}"
}
