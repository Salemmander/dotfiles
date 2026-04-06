---
name: task
description: Manage Taskwarrior todos. Add, start, complete, and query tasks. Invoke with /task or triggered when user mentions work to do.
allowed-tools: Bash(task *)
---

# Taskwarrior

User uses Taskwarrior v3 (SQLite-backed, data at `~/.task/taskchampion.sqlite3`).

## Invocation

- `/task` or `/task <action>` -- explicit use
- Auto-trigger when user mentions work to do, asks about their tasks, or wants to mark something done. When the user refers to a task by rough description, always start with `task next` and match from the full list -- never filter with `description.contains:` since the user's phrasing won't match the saved description exactly

## Conventions

- **Description**: keep short (a few words)
- **Priority**: always set one. H = urgent, M = normal, L = low/unclear
- **Project**: repo name (e.g., `project:auth-service`). Omit if not repo-specific
- **Tags**: one of `+bug`, `+feature`, `+chore`, `+blocked`. No custom tags unless user asks
- **Due dates**: only when user explicitly mentions a deadline
- **Dependencies**: `task <id> modify depends:<other_id>` when ordering matters
- **Annotations**: `task <id> annotate "..."` only when there's meaningful context that doesn't fit the description

## Workflow

1. **Adding**: `task add <desc> priority:<H|M|L> [project:<name>] [+tag]`. If priority, tag, or project isn't clear from context, ask before adding.
2. **Starting**: `task <id> start` when we begin working on something that matches a task
3. **Completing**: `task <id> done` when work is finished in-session. If unsure, ask user to confirm.
4. **Querying**: `task next` to see all pending tasks. Use this as the starting point whenever looking up a task -- scan the list and match by intent, not exact wording. Only check when contextually relevant -- never at conversation start.
