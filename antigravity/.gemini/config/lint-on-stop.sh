#!/bin/bash

# Run ruff check --fix on .py files edited this session.
# Fires on the Stop event, after all agent edits are complete.
# If unfixable lint errors remain on a normal stop, bounce once back to the agent.

export PATH="$HOME/.local/share/nvim/mason/bin:$HOME/.local/bin:$PATH"

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.conversationId // "default"')
termination_reason=$(printf '%s' "$input" | jq -r '.terminationReason // ""')
continuation_active=$(printf '%s' "$input" | jq -r '.continuationActive // false')

tmpfile="/tmp/agy-ruff-${session_id}.txt"

if [ ! -f "$tmpfile" ] || ! command -v ruff &>/dev/null; then
	rm -f "$tmpfile"
	printf '{"decision":"stop"}\n'
	exit 0
fi

mapfile -t files < <(sort -u "$tmpfile" | while IFS= read -r f; do [ -f "$f" ] && printf '%s\n' "$f"; done)
rm -f "$tmpfile"

if [ "${#files[@]}" -eq 0 ]; then
	printf '{"decision":"stop"}\n'
	exit 0
fi

ruff check --fix "${files[@]}" >/dev/null 2>&1

if [ "$termination_reason" = "NO_TOOL_CALL" ] && [ "$continuation_active" != "true" ]; then
	remaining=$(ruff check --output-format concise "${files[@]}" 2>/dev/null | head -n 40)
	if [ -n "$remaining" ]; then
		jq -nc --arg reason "Ruff reported unfixable lint errors in edited Python files — please fix them:
$remaining" '{decision: "continue", reason: $reason}'
		exit 0
	fi
fi

printf '{"decision":"stop"}\n'
exit 0
