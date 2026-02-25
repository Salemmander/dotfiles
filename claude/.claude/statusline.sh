#!/bin/bash
cwd=$(cat | jq -r '.workspace.current_dir')
cd "$cwd" 2>/dev/null || exit 0
STARSHIP_SHELL=plain starship prompt 2>/dev/null | sed '/^$/d' | head -1
exit 0
