#!/bin/bash
cwd=$(cat | jq -r '.workspace.current_dir // .cwd // empty')
[ -n "$cwd" ] || exit 0
cd "$cwd" 2>/dev/null || exit 0
STARSHIP_SHELL=plain starship prompt 2>/dev/null | sed '/^$/d' | head -1
exit 0
