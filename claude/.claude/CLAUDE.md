# User Preferences

- Never include the Claude Code reference or Co-Authored-By line in commit messages
- Never use emojis in any files
- Avoid using `cd` to change directories in bash commands. Trust the current working directory and run commands directly (e.g., use `git status` not `git -C /path status` when already in the repo).
- Always place imports at the top of the file, never inside functions or methods

# Task Management

- User uses **Taskwarrior** (v3, SQLite-backed) for todo tracking
- Data lives at `~/.task/taskchampion.sqlite3`
- IMPORTANT: Always run `task next` at the start of every conversation and present a brief summary grouped by priority (H/M/L) with task descriptions
- When user mentions work to do, add it with `task add`. If priority, tag, or project isn't clear from context, use AskUserQuestion to confirm before adding
- When work is completed, mark it with `task <id> done`
- Conventions:
  - project: = repo name (e.g., project:auth-service). Leave blank if task doesn't belong to a specific repo
  - Tags: +bug, +feature, +chore (pick one per task), +blocked (when waiting on someone/something)
  - Only use tags from this list. Do not create new tags unless user explicitly asks
  - Priority: always set one. H = urgent, M = normal, L = low/unclear
  - Due dates: only when user explicitly mentions a deadline
