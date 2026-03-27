---
name: commit
model: haiku
context: fork
description: Stage, commit, and push changes. Drafts a commit message then commits and pushes with permission approval.
allowed-tools: Bash(git *)
---

## Invocation

`/commit [path]` — `path` can be an absolute path or a repo name. If a repo name is given, resolve it to a full path by searching under `~/Documents/Projects/`. Then prefix all git commands with `git -C <resolved-path>`.

## Safety Rules

- NEVER use `git add -A` or `git add .` -- always stage specific files by name
- NEVER use `--no-verify` or `--amend`
- NEVER force push (`--force`, `--force-with-lease`)
- NEVER push to `main` or `master` without explicitly warning the user first
- Warn about files that look like secrets: `.env`, `credentials`, `*.key`, `*.pem`, `*.secret`, tokens, passwords

## Instructions

### Step 1: Review changes

Run in parallel: `git status`, `git diff HEAD`, `git log --oneline -5`.

If there are no changes, tell the user and stop.

If any files look like secrets (`.env`, `credentials.*`, `*.key`, `*.pem`, `*.secret`), warn the user and ask before continuing.

### Step 2: Stage files

Check what is already staged:

```bash
git diff --cached --name-only
```

Then stage any remaining relevant files by name. If it's ambiguous which files to include, ask the user.

### Step 3: Draft commit message

Run `git diff --cached` and draft a commit message:

- Summary: imperative mood, under 72 chars (e.g. "Add feature" not "Added feature")
- Body: what changed and why, wrapped at 72 chars. Omit if the change is trivial.
- Match the style of recent commits from Step 1.

Display the message to the user, then proceed.

### Step 4: Commit

Use `-m` for the summary and a second `-m` for the body. Never use a heredoc — it breaks permission matching.

```bash
git commit -m "Summary line" -m "Body paragraph."
```

### Step 5: Push

Check the branch and upstream:

```bash
git rev-parse --abbrev-ref @{upstream} 2>/dev/null
```

If on `main` or `master`, warn the user. The permission system will prompt for push approval — do NOT use AskUserQuestion.

Push with `git push`, or `git push -u origin <branch>` if no upstream exists.

Report the commit hash, branch, and push status in a single line.
