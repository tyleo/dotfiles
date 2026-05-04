#!/bin/bash
# Claude Code status line
# Format: CCCCCCCCCC ##%  {robot} Model Name [effort] | ~/git/repo   branch-name

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

YELLOW=$'\033[93m'
ORANGE=$'\033[38;5;214m'
GREEN=$'\033[92m'
BLUE=$'\033[96m'
RESET=$'\033[0m'

# Context bar
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
    pct_int=$(printf "%.0f" "$used_pct")
    bar_filled=$(( pct_int / 10 ))
    bar_empty=$(( 10 - bar_filled ))
    bar=""
    i=0
    while [ $i -lt $bar_filled ]; do
        bar="${bar}▓"
        i=$(( i + 1 ))
    done
    i=0
    while [ $i -lt $bar_empty ]; do
        bar="${bar}░"
        i=$(( i + 1 ))
    done
    pct_str=$(printf '%02d' "$pct_int")
    context_part="${YELLOW}${bar} ${pct_str}%${RESET}"
else
    context_part="${YELLOW}░░░░░░░░░░ 00%${RESET}"
fi

# Model name: strip leading "Claude " to get e.g. "Sonnet 4.6", "Opus 4"
model_display=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model_display" ]; then
    short_model=$(echo "$model_display" | sed 's/^Claude //')
else
    short_model=""
fi

# Effort level (only present when model supports reasoning effort)
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
if [ -n "$effort_level" ]; then
    effort_str=" @ ${effort_level}"
else
    effort_str=""
fi

# Model segment (bolt icon U+F0E7 = nf-fa-bolt, encoded as \xef\x83\xa7)
magic_icon=$(printf '\xef\x83\xa7')
if [ -n "$short_model" ]; then
    model_part=" ${ORANGE}${magic_icon} ${short_model}${effort_str}${RESET}"
else
    model_part=""
fi

# Directory
home="$HOME"
display_dir=$(echo "$cwd" | sed "s|^$home|~|")

# Git branch (skip optional locks to avoid contention)
branch_part=""
if git -C "$cwd" -c core.fsmonitor= rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" -c core.fsmonitor= symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" -c core.fsmonitor= rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        branch_icon=$(printf '\xee\x82\xa0')
        branch_part=" ${BLUE}${branch_icon} ${branch}${RESET}"
    fi
fi

echo "${context_part}${model_part} | ${GREEN}${display_dir}${RESET}${branch_part}"
