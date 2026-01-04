#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
cd "$cwd" 2>/dev/null || exit 0

# Replace $HOME with ~
cwd="${cwd/#$HOME/\~}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # In git repo: show repo name (bold cyan) + relative path
    repo=$(basename "$(git rev-parse --show-toplevel)")
    rel=$(git rev-parse --show-prefix 2>/dev/null | sed 's/\/$//')
    if [ -n "$rel" ]; then
        printf '\033[1;36m%s\033[0m/%s ' "$repo" "$rel"
    else
        printf '\033[1;36m%s\033[0m ' "$repo"
    fi

    # Git branch (italic cyan)
    branch=$(git branch --show-current 2>/dev/null)
    [ -n "$branch" ] && printf '\033[3;36m%s\033[0m ' "$branch"

    # Git status (cyan)
    st=''
    [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ] && st="${st}? "
    git diff --quiet 2>/dev/null || st="${st} "
    [ -n "$st" ] && printf '\033[36m%s\033[0m' "$st"
else
    # Outside git repo: truncate to last 3 dirs with …/ prefix
    # Count slashes to determine depth
    depth=$(echo "$cwd" | tr -cd '/' | wc -c)
    if [ "$depth" -le 3 ]; then
        # Short path, show as-is
        printf '\033[1;36m%s\033[0m ' "$cwd"
    else
        # Truncate: …/dir1/dir2/dir3
        truncated=$(echo "$cwd" | awk -F/ '{printf "…/%s/%s/%s", $(NF-2), $(NF-1), $NF}')
        printf '\033[1;36m%s\033[0m ' "$truncated"
    fi
fi
exit 0
