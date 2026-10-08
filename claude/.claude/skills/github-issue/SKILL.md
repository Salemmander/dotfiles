---
name: github-issue
description: Work a GitHub issue end to end — create a linked branch, implement, test, commit, and open a draft PR. Invoke with /github-issue <number>, or when the user says to work on / pick up / fix a GitHub issue #N.
allowed-tools: Bash(gh *), Bash(git *), Bash(poetry run *)
---

`/github-issue <n> [path]` — `path` is an absolute path or a repo name under `~/Documents/Projects/`. If given, `cd` there first.

Work autonomously. Stop and ask only if the issue is too vague to act on or the fix needs a product decision.

## Steps

1. **Read.** `gh issue view <n> --comments`. Note the acceptance criteria and any linked PRs or branches (`gh issue develop <n> --list`).
2. **Branch.** If there are uncommitted changes, stop and report them. If the current branch already starts with `<n>-`, stay on it and skip to step 3. Otherwise, create a remote branch linked to the issue and check it out:

   ```bash
   gh issue develop <n> --name <n>-<short-slug> --checkout
   ```

   Slug: 2–4 lowercase words from the title, dash-separated.
3. **Implement.** Make the change. Keep scope to what the issue asks.
4. **Verify.** Run the project's tests and linter. Fix failures you caused. If you can't get them passing, keep going but say so in the report.
5. **Commit.** Use the `commit` skill. It pushes, because the branch isn't main/master.
6. **PR.** If `gh pr view --json url` finds a PR for this branch, it already updated on push; skip. Otherwise open a draft (GitHub won't open one without commits, so this comes after the first push):

   ```bash
   gh pr create --draft --title "<issue title>" --body "Closes #<n>

   <1–3 line summary>"
   ```

## Rules

- Never commit to or push main/master.
- One issue per branch. Don't fold in unrelated fixes; mention them in the report instead.
- Draft PRs only. The user marks them ready.

## Report

```
#<n> <title>
<branch> — <PR url>
<1–3 lines: what changed, test status, anything left open>
```
