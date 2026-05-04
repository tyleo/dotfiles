#!/bin/bash
# Claude Code status line
# Format: CCCCCCCCCC ##% | ~/git/star-shift   branch-name

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

YELLOW='\033[93m'
GREEN='\033[92m'
BLUE='\033[96m'
RESET='\033[0m'

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
    context_part="${YELLOW}${bar} ${pct_int}%${RESET}"
else
    context_part="${YELLOW}░░░░░░░░░░ 00%${RESET}"
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

echo -e "${context_part} | ${GREEN}${display_dir}${RESET}${branch_part}"
