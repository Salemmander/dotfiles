---
name: mr
model: haiku
context: fork
description: Create a GitLab merge request using glab. Drafts title and description from branch history, then opens an MR with confirmation.
allowed-tools: Bash(git *), Bash(glab mr *)
---

## Invocation

`/mr [options]` — create a merge request for the current branch.

Optional args passed verbatim to `glab mr create` (e.g. `--draft`, `--label foo`, `--reviewer username`).

## Instructions

### Step 1: Gather context

Run in parallel:

```bash
git rev-parse --abbrev-ref HEAD
git log --oneline origin/HEAD..HEAD
git diff origin/HEAD..HEAD --stat
```

If the branch has no commits ahead of origin/HEAD, tell the user there is nothing to open an MR for and stop.

### Step 2: Draft title and description

From the commit list and diff stat, draft:

- **Title**: imperative mood, under 72 chars. Use the single commit subject if there is only one commit; otherwise write a summary of the set.
- **Description**: a short summary of what changed and why, in plain prose. If there are multiple commits, list them as bullets. Keep it under 10 lines.

### Step 3: Show the draft

Print the proposed title and description to the user. Do not pause to ask for approval — proceed directly to Step 4.

### Step 4: Create the MR

Run:

```bash
glab mr create \
  --title "<title>" \
  --description "<description>" \
  --remove-source-branch \
  [any args the user passed]
```

The permission system will prompt for approval before running — do NOT use AskUserQuestion for this.

### Step 5: Report

Print the MR URL returned by glab.
