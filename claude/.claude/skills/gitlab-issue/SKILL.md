---
name: gitlab-issue
description: Work a GitLab issue end to end — open a draft MR with its branch, implement, test, and commit. Invoke with /gitlab-issue <number>, or when the user says to work on / pick up / fix a GitLab issue #N.
allowed-tools: Bash(glab *), Bash(git *), Bash(poetry run *)
---

`/gitlab-issue <n> [path]` — `path` is an absolute path or a repo name under `~/Documents/Projects/`. If given, `cd` there first.

Work autonomously. Stop and ask only if the issue is too vague to act on or the fix needs a product decision.

## Steps

1. **Read.** `glab issue view <n> --comments`. Note the acceptance criteria and any linked MRs.
2. **Branch + MR.** If there are uncommitted changes, stop and report them. If the current branch already starts with `<n>-`, stay on it and skip to step 3. Otherwise, create the remote branch and draft MR together, then check it out:

   ```bash
   glab mr create -i <n> --create-source-branch -s <n>-<short-slug> --remove-source-branch --draft --yes
   git fetch origin
   git switch <n>-<short-slug>
   ```

   Slug: 2–4 lowercase words from the title, dash-separated.
3. **Implement.** Make the change. Keep scope to what the issue asks.
4. **Verify.** Run the project's tests and linter. Fix failures you caused. If you can't get them passing, keep going but say so in the report.
5. **Commit.** Use the `commit` skill. It pushes, because the branch isn't main/master, and the MR updates on its own.

## Rules

- Never commit to or push main/master.
- One issue per branch. Don't fold in unrelated fixes; mention them in the report instead.
- Draft MRs only. The user marks them ready.

## Report

```
#<n> <title>
<branch> — <MR url>
<1–3 lines: what changed, test status, anything left open>
```
