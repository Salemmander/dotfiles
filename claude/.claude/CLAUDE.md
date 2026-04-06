@~/.claude/local.md

# Self-Correction

- When the user corrects a repetitive behavior or pattern mistake, use the AskUserQuestion tool with a yes/no to ask if they want the rule added to this CLAUDE.md file so it persists across all future conversations.

# User Preferences

- Never use emojis in any files
- Always place imports at the top of the file, never inside functions or methods

# Ad-hoc Python

- For running Python code that is NOT part of a project (e.g., API calls, one-off scripts, data processing), use `uv run --with <package> python ...` instead of bare `python` or `pip install`
- Multiple packages: `uv run --with pkg1 --with pkg2 python script.py`
- This avoids polluting any project's virtualenv. `uv` caches packages so repeat runs are fast

# Behavior

- Confirm your approach before editing files -- especially when debugging or making multi-file changes
- Show raw output from commands, queries, and skills. Do not summarize or truncate unless asked
- Focus on root cause analysis. Do not suggest workarounds unless the user asks or root cause is confirmed out of scope
- Be concise by default. When the user asks "why" or "how does X work", or the topic is clearly new to them, give full detail

# Task Management

- User uses Taskwarrior for todo tracking -- see `/task` skill for conventions and workflow
