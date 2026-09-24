---
name: weekly-update
description: Generate a weekly status update from git commit history, weekly notes, and completed tasks.
disable-model-invocation: true
allowed-tools: Bash(*), Read, Write, Edit("weekly-updates/*")
context: fork
model: sonnet
---

# Weekly Update Generator

## Steps

**1. Date range** — Calculate Monday of current week through today:

```bash
day_of_week=$(date +%u)
monday_date=$(date -v-$((day_of_week - 1))d +%Y-%m-%d)
end_date=$(date -v+1d +%Y-%m-%d)
```

**2. Gather data** — Run all four of these in parallel as separate Bash calls:

a) **Previous update** — `ls -1 /Users/nasa68p/Documents/Projects/weekly-updates/weekly-update-*.md | tail -1` then read it. Extract upcoming work items to carry forward.

b) **Weekly notes** — Read `weekly-updates/weekly-notes.md` if it exists. Notes take priority over commit data. Do not modify this file.

c) **Completed tasks** — `task status:completed end.after:[monday_date] export`. Match to project sections by `project` field.

d) **Collect commits** — Run in a single Bash call:

```bash
for repo in $(fd -H -t d -I "^\.git$" /Users/nasa68p/Documents/Projects/*-projects | sed 's|/.git||' | sort); do
  commits=$(git -C "$repo" log --all --author="salem.nassar@verizonwireless.com" --since="[monday_date]" --until="[end_date]" --pretty=format:"COMMIT_START%n%s%n%b%nCOMMIT_END%n")
  [ -z "$commits" ] && continue
  echo "=== $repo ==="
  echo "$commits"
  git -C "$repo" log --all --author="salem.nassar@verizonwireless.com" --since="[monday_date]" --until="[end_date]" --stat --oneline
  git -C "$repo" branch -a --sort=-committerdate | head -5
done
```

**3. Carry forward upcoming work** — If commits/notes show it's done, move to accomplishments; if blocked/in-progress or no evidence, keep in upcoming. Do not ask the user.

**4. Write the report** — Output to `weekly-updates/weekly-update-[monday_date].md`. Overwrite if it already exists. Tell the user it's ready and ask for changes.

## Project grouping

- `aspn-projects/` → ASPN
- `nautobot-projects/` → Nautobot
- `ufb-projects/` → Unified File Builder
- `vault-projects/` → Vault

Only include project sections that have activity (commits, notes, or completed tasks). Skip empty groups.

## Output format

```
**Salem Nassar - [Project]**

* **Weekly accomplishments**
  * Short bullet here
* **Upcoming work**
  * Item here


```

Repeat for each project. Two blank lines between sections. No markdown headers. Use `*` for list markers (not `-`), two-space indentation for nested items.

## Writing rules

- Write for senior leadership -- outcomes, not technical details
- One concise line per bullet, no over-explaining
- No jargon: no file paths, function names, CLI commands, config file names
- Merged to master: confident verbs (Built, Completed, Added, Fixed)
- Feature branch only: cautious verbs (Started, Began)
- Combine related commits into one bullet
- Upcoming: carry forward from previous week + inferred from commits/notes; use `TODO: Fill in upcoming work` if nothing known

## Examples

BAD: "Migrated API key from URL query params to X-API-Key request header"
GOOD: "Improved API security by updating credential handling"

BAD: "Created Terraform modules and refactored .tf files"
GOOD: "Started migrating Nautobot deployments to Terraform"

## Wrap-up

Confirm file path, number of repos/commits processed, and remind user to clear `weekly-notes.md`.
