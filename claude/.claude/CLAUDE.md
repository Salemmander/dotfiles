@~/.claude/local.md

# Self-Correction

- When the user corrects a repetitive behavior or pattern mistake, use the AskUserQuestion tool with a yes/no to ask if they want the rule added to this CLAUDE.md file so it persists across all future conversations.

# User Preferences

- Never include the Claude Code reference or Co-Authored-By line in commit messages
- Never use emojis in any files
- Avoid using `cd` to change directories in bash commands. Trust the current working directory and run commands directly (e.g., use `git status` not `git -C /path status` when already in the repo).
- Always place imports at the top of the file, never inside functions or methods

# Code Editing Rules

- A `ruff check --fix` post-edit hook auto-removes unused imports. When adding a new import, always include it in the **same edit** as the code that uses it. Never add an import in one edit and the usage in a separate edit -- ruff will strip it in between. If the import and usage are in different parts of the file, make a single larger edit covering both.

# Task Management

- User uses **Taskwarrior** (v3, SQLite-backed) for todo tracking
- Data lives at `~/.task/taskchampion.sqlite3`
- Check tasks (`task next`) only when contextually relevant -- e.g., user asks about their tasks, starts working on something, or wants to mark work done. Do NOT check at the start of every conversation
- When user mentions work to do, add it with `task add`. If priority, tag, or project isn't clear from context, use AskUserQuestion to confirm before adding
- When we start working on something that matches a task, mark it started with `task <id> start`
- When work is completed together in a session, mark it done with `task <id> done`. Otherwise ask/wait for user to confirm
- Keep task descriptions short (a few words)
- Conventions:
  - project: = repo name (e.g., project:auth-service). Leave blank if task doesn't belong to a specific repo
  - Tags: +bug, +feature, +chore (pick one per task), +blocked (when waiting on someone/something)
  - Only use tags from this list. Do not create new tags unless user explicitly asks
  - Priority: always set one. H = urgent, M = normal, L = low/unclear
  - Due dates: only when user explicitly mentions a deadline
  - Dependencies: use `task <id> modify depends:<other_id>` when one task must complete before another. Taskwarrior will color blocking tasks differently (purple) to show they're on the critical path
  - Annotations: use `task <id> annotate "..."` to attach extra context when a task has details that don't fit in the short description (e.g., approach notes, blockers, links). Not every task needs one -- only annotate when there's meaningful context to preserve
