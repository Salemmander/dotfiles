---
name: commit
description: Stage, commit, and optionally push changes. Shows diff, drafts a commit message for approval, and asks before pushing.
allowed-tools: Bash(git *), Bash(date *)
---

# Commit and Push

Stage, commit, and optionally push git changes interactively.

## Invocation

```
/commit [path]
```

- `path` (optional): Path to a git repo. If provided, prefix all git commands with `git -C <path>`. If omitted, use the current working directory.

## Safety Rules

- NEVER use `git add -A` or `git add .` -- always stage specific files by name
- NEVER use `--no-verify` or `--amend`
- NEVER force push (`--force`, `--force-with-lease`)
- NEVER push to `main` or `master` without explicitly warning the user first
- Always create NEW commits, never amend existing ones
- Use `-m` flags for commit messages (multiple `-m` for subject + body) to keep commands single-line
- Warn about files that look like secrets: `.env`, `credentials`, `*.key`, `*.pem`, `*.secret`, tokens, passwords

## Instructions

### Step 1: Review changes

Run these in parallel:

```bash
git status
```

```bash
git diff
```

```bash
git log --oneline -5
```

Review the output. If there are no changes (nothing to commit), tell the user and stop.

Check for files that look like secrets (`.env`, `credentials.*`, `*.key`, `*.pem`, `*.secret`). If any are present in the changes, warn the user and ask if they really want to include them.

### Step 2: Stage files

Stage the relevant changed files by name. Include both modified and new (untracked) files that are part of the logical change.

If it's ambiguous which files to include (e.g., there are unrelated changes mixed in), ask the user which files to stage.

```bash
git add file1.py file2.py ...
```

### Step 3: Draft commit message

Analyze the staged diff (`git diff --cached`) and draft a commit message following this format:

```
Short imperative summary (under 72 chars)

Body with context: what changed and why. Wrap at 72 chars.
Separate from summary with blank line.
```

Rules for auto-generated messages:

- Summary line: imperative mood ("Add feature" not "Added feature"), under 72 chars
- Body: explain what changed and why, not how. Wrap at 72 chars.
- If the change is trivial (single small edit), the body can be omitted
- Match the style of recent commits shown in Step 1

### Step 4: Confirm commit message

Display the full commit message to the user and ask for approval using AskUserQuestion:

- "Looks good" -- proceed with this message
- "Edit" -- ask what to change, then re-display
- "Abort" -- unstage (`git reset HEAD`) and stop (working directory changes are kept)

### Step 5: Commit

Create the commit using `-m` flags. Use one `-m` for the summary and a second `-m` for the body (git will separate them with a blank line automatically). If the change is trivial and has no body, use a single `-m`.

```bash
git commit -m "Summary line" -m "Body paragraph."
```

Show the resulting commit hash.

### Step 6: Push

Check what branch we're on:

```bash
git branch --show-current
```

If the branch is `main` or `master`, warn the user that they're about to push directly to the default branch.

Check if the branch has an upstream:

```bash
git rev-parse --abbrev-ref @{upstream} 2>/dev/null
```

Push the commit. The permission system will prompt the user for approval, so do NOT use AskUserQuestion here (that would double-prompt).

If the branch has an upstream:

```bash
git push
```

If no upstream:

```bash
git push -u origin <branch>
```

### Step 7: Confirm

Report:

- Commit hash
- Branch name
- Whether it was pushed
- A short summary (e.g., "Committed and pushed 3 files to feature/xyz")
