#!/bin/bash

# Run ruff check --fix on .py files edited this session.
# Fires on the Stop event, after all Claude edits are complete.

export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

session_id=$(cat | jq -r '.session_id // "default"')
tmpfile="/tmp/claude-ruff-${session_id}.txt"

if [ ! -f "$tmpfile" ]; then
	exit 0
fi

sort -u "$tmpfile" | while read -r f; do
	[ -f "$f" ] && ruff check --fix "$f" 2>/dev/null
done

rm -f "$tmpfile"
exit 0
