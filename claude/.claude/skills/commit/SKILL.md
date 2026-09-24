---
name: commit
model: haiku
context: fork
description: Stage, commit, and push changes autonomously. Never pushes to main/master. Reports the commit message.
allowed-tools: Bash(git *)
---

`/commit [path]` — `path` is an absolute path or a repo name under `~/Documents/Projects/`. If given, use `git -C <path>` for every command.

Run end to end without asking questions.

## Rules

- Stage files by name. Never `git add -A` / `git add .`
- Never `--no-verify`, `--amend`, or force push
- Skip anything that looks like a secret (`.env`, `credentials*`, `*.key`, `*.pem`, `*.secret`, tokens) — don't stage it
- **Never push to `main` or `master`.** Commit locally and stop.

## Steps

1. Run `git status`, `git diff HEAD`, `git log --oneline -5` in parallel. If nothing changed, say so and stop.
2. Stage all changed files except secrets.
3. Write the message from `git diff --cached`: imperative summary under 72 chars, optional body wrapped at 72, matching recent commit style.
4. Commit with `git commit -m "Summary" -m "Body"`. Don't use a heredoc; it breaks permission matching.
5. Check the branch with `git branch --show-current`. If it's `main` or `master`, skip the push. Otherwise run `git push`, or `git push -u origin <branch>` if there's no upstream.

## Report

Output only:

```
<commit message>

<short-hash> on <branch> — pushed | not pushed (main/master) | push failed: <reason>
```

Add one line listing any files skipped as secrets.
