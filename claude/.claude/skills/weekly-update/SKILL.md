---
name: weekly-update
description: Generate a weekly status update from this week's git commits and weekly notes.
disable-model-invocation: true
allowed-tools: Bash(*), Read, Write
context: fork
model: sonnet
---

All files live in `~/Documents/Projects/weekly-updates/`. Run end to end without asking questions.

## Steps

1. **Dates.** `monday=$(date -v-$(( $(date +%u) - 1 ))d +%Y-%m-%d)` and `end=$(date -v+1d +%Y-%m-%d)`.
2. **Gather** (in parallel):
   - The latest `weekly-update-*.md`, for last week's upcoming work.
   - `weekly-notes.md`, if it exists. Notes take priority over commits. Don't modify it.
   - This week's commits:

     ```bash
     for repo in $(fd -H -t d -I '^\.git$' ~/Documents/Projects/*-projects | sed 's|/.git/*$||' | sort); do
       log=$(git -C "$repo" log --all --author=salem.nassar@verizonwireless.com --since="$monday" --until="$end" --pretty='%s%n%b')
       [ -n "$log" ] && printf '=== %s ===\n%s\n' "$repo" "$log"
     done
     ```

3. **Carry forward.** Last week's upcoming items move to accomplishments if the commits or notes show them done. Otherwise they stay upcoming.
4. **Write** `weekly-update-<monday>.md`, overwriting if it exists.

## Format

One section per project group with activity: `aspn-projects` = ASPN, `nautobot-projects` = Nautobot, `ufb-projects` = Unified File Builder, `vault-projects` = Vault. Any other folder: use the repo name.

```
**Salem Nassar - [Project]**

* **Weekly accomplishments**
  * Short bullet here
* **Upcoming work**
  * Item here


```

Two blank lines between sections. No headers. `*` markers, two-space indent.

## Writing

- For senior leadership: outcomes, not technical details. One line per bullet.
- No file paths, function names, commands, or config names.
- Merged to master: confident verbs (Built, Completed, Fixed). Feature branch only: Started, Began.
- Combine related commits. If nothing is known for upcoming, write `TODO: Fill in upcoming work`.
- Example: "Migrated API key to X-API-Key header" becomes "Improved API security by updating credential handling".

## Report

File path, repos and commits counted, and a reminder to clear `weekly-notes.md`.
