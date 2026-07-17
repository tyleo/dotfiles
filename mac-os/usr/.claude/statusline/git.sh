#!/bin/bash

# Statusline segment: git branch and status. Sourced by statusline.sh.

# Pull the working directory out of the statusline JSON:
# workspace.current_dir, or cwd when unset.
git_segment_cwd() {
    printf '%s' "$1" | jq -r '
        .workspace.current_dir as $w |
        if $w == null or $w == "" then .cwd // "" else $w end' 2>/dev/null
}

# nf-pl-branch | U+E0A0
format_git_icon() { printf '\xee\x82\xa0'; }

# Git: branch (or short SHA on detached HEAD), plus posh-git-style
# status counts; ? outside a git repo. One `git status` fork covers branch +
# ahead/behind + file states; stash count is read directly from the reflog
# file. Arg: statusline JSON.
format_git() {
    local cwd
    cwd=$(git_segment_cwd "$1")
    [ -z "$cwd" ] && { printf '?'; return; }
    local porcelain
    porcelain=$(git -C "$cwd" -c core.fsmonitor= --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || { printf '?'; return; }
    local branch="" oid=""
    local ahead=0 behind=0 conflicted=0 staged=0 renamed=0 deleted=0 modified=0 untracked=0
    while IFS= read -r line; do
        case "$line" in
            "# branch.head "*) branch=${line#"# branch.head "} ;;
            "# branch.oid "*) oid=${line#"# branch.oid "} ;;
            "# branch.ab "*)
                local ab=${line#"# branch.ab "}
                ahead=${ab%% *}; ahead=${ahead#+}
                behind=${ab##* }; behind=${behind#-}
                ;;
            "1 "*)
                local x=${line:2:1} y=${line:3:1}
                case "$x" in [MTADC]) staged=$((staged + 1)) ;; esac
                case "$y" in
                    M|T) modified=$((modified + 1)) ;;
                    D) deleted=$((deleted + 1)) ;;
                esac
                ;;
            "2 "*) renamed=$((renamed + 1)) ;;
            "u "*) conflicted=$((conflicted + 1)) ;;
            "? "*) untracked=$((untracked + 1)) ;;
        esac
    done <<EOF
$porcelain
EOF
    [ "$branch" = "(detached)" ] && branch=${oid:0:7}
    [ -z "$branch" ] && { printf '?'; return; }

    # Stash count from reflog file (no fork). Misses linked-worktree stashes.
    local stashed=0 _line
    if [ -f "$cwd/.git/logs/refs/stash" ]; then
        while IFS= read -r _line; do stashed=$((stashed + 1)); done < "$cwd/.git/logs/refs/stash"
    fi

    local s=""
    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then s="${s}↕ ↑${ahead} ↓${behind} "
    elif [ "$ahead" -gt 0 ]; then s="${s}↑${ahead} "
    elif [ "$behind" -gt 0 ]; then s="${s}↓${behind} "
    fi
    [ "$conflicted" -gt 0 ] && s="${s}✖${conflicted} "
    [ "$stashed" -gt 0 ] && s="${s}\$${stashed} "
    [ "$staged" -gt 0 ] && s="${s}+${staged} "
    [ "$renamed" -gt 0 ] && s="${s}»${renamed} "
    [ "$deleted" -gt 0 ] && s="${s}-${deleted} "
    [ "$modified" -gt 0 ] && s="${s}!${modified} "
    [ "$untracked" -gt 0 ] && s="${s}?${untracked} "

    local status=""
    [ -n "$s" ] && status=" [${s% }]"
    printf '%s' "${branch}${status}"
}

# nf-pl-branch | U+E0A0
format_git_no_status_icon() { printf '\xee\x82\xa0'; }

# Git (no status): branch only, short SHA on detached HEAD; ? outside a git
# repo. symbolic-ref also names unborn branches, which rev-parse cannot.
# Arg: statusline JSON.
format_git_no_status() {
    local cwd
    cwd=$(git_segment_cwd "$1")
    [ -z "$cwd" ] && { printf '?'; return; }
    local branch
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short -q HEAD 2>/dev/null)
    [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -z "$branch" ] && { printf '?'; return; }
    printf '%s' "$branch"
}
