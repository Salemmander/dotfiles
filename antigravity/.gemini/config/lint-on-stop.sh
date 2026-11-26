#!/bin/bash

# Run ruff check --fix on .py files edited this session.
# Fires on the Stop event, after all agent edits are complete.

export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

session_id=$(cat | jq -r '.conversationId // "default"')
tmpfile="/tmp/agy-ruff-${session_id}.txt"

if [ -f "$tmpfile" ]; then
	sort -u "$tmpfile" | while read -r f; do
		[ -f "$f" ] && ruff check --fix "$f" >/dev/null 2>&1
	done
	rm -f "$tmpfile"
fi

printf '{"decision":"stop"}\n'
exit 0
