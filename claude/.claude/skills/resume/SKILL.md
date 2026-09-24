---
name: resume
description: Generate resume-ready accomplishments from all git history, weekly updates, and completed tasks.
allowed-tools: Bash(*), Read, Write, Glob
context: fork
model: sonnet
---

# Resume Accomplishments Generator

Generate a resume-formatted markdown file from all historical work data.

## Steps

**1. Gather data** -- Run all three of these in parallel as separate Bash calls:

a) **All weekly updates** -- Glob for `~/Documents/Projects/weekly-updates/weekly-update-*.md`, then read every file. Extract all accomplishment bullets (lines under "Weekly accomplishments"). These are already polished -- they take priority over raw commit messages when deduplicating.

b) **All git repos** -- Run in a single Bash call. This collects five things per repo: commit messages with dates, commit count, branch names (feature areas), project structure (technologies used), and total scope of changes.

```bash
for repo in $(fd -H -t d -I "^\.git$" /Users/nasa68p/Documents/Projects/*-projects | sed 's|/.git||' | sort); do
  count=$(git -C "$repo" log --all --author="salem.nassar@verizonwireless.com" --oneline 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" = "0" ] && continue
  echo "=== $repo ==="

  echo "--- commits ($count total) ---"
  git -C "$repo" log --all --author="salem.nassar@verizonwireless.com" --pretty=format:"%ad | %s" --date=short

  echo ""
  echo "--- branches ---"
  git -C "$repo" branch -a --sort=-committerdate 2>/dev/null | head -15

  echo ""
  echo "--- project structure ---"
  tree -L 2 -d --noreport "$repo" 2>/dev/null || ls -d "$repo"/*/ 2>/dev/null

  echo ""
  echo "--- total scope ---"
  root_commit=$(git -C "$repo" rev-list --max-parents=0 HEAD 2>/dev/null | head -1)
  if [ -n "$root_commit" ]; then
    git -C "$repo" diff --stat "$root_commit"..HEAD 2>/dev/null | tail -1
  fi
  echo ""
done
```

After the repo loop, run a second Bash call to get the exact date range:

```bash
for repo in $(fd -H -t d -I "^\.git$" /Users/nasa68p/Documents/Projects/*-projects | sed 's|/.git||' | sort); do
  git -C "$repo" log --all --author="salem.nassar@verizonwireless.com" --pretty=format:"%ad" --date=short 2>/dev/null
done | sort | sed -n '1p;$p'
```

This outputs two lines: the earliest and latest commit dates. Use these exact dates for the "based on work from X to Y" line in the output. Do not infer or guess dates.

c) **All completed tasks** -- `task status:completed export`

**2. Deduplicate and merge** -- Weekly update bullets are pre-polished. Use them as the primary source. Fill in gaps with commit data and completed tasks that aren't already covered by a weekly update bullet. Do not include duplicate or near-duplicate entries.

**3. Categorize by theme** -- Group accomplishments into thematic sections based on the nature of the work, NOT by repository. Choose from these categories (only include categories with content):

- **Automation & Provisioning** -- automated workflows, service request processing, config generation
- **Infrastructure & Platform** -- deployments, Terraform/OpenTofu, OpenShift, CI/CD pipelines
- **Integration & Tooling** -- API integrations, plugins, credential management, SSoT syncing
- **Security & Compliance** -- Vault, secrets management, certificate handling, CyberArk
- **Observability & Operations** -- monitoring, logging, database management, disaster recovery

If a bullet fits multiple categories, place it in the most impactful one.

**4. Extract technical skills** -- Scan commits, weekly updates, and repo contents to identify:

- **Languages** -- programming languages used (Python, etc.)
- **Platforms** -- infrastructure and platforms (OpenShift, GitLab CI/CD, Nautobot, etc.)
- **Tools & Frameworks** -- development tools (Terraform/OpenTofu, Poetry, Docker, Ansible, etc.)
- **Vendor Systems** -- network vendor platforms worked with (Cisco, Ericsson, Nokia, Casa, etc.)

Only include skills with clear evidence in the data. Do not guess.

**5. Write the output** -- Write to `~/Documents/Projects/resume-updates/resume-accomplishments.md`. Create the directory if it doesn't exist. Overwrite if the file already exists.

## Output format

```markdown
# Resume Accomplishments

*Generated YYYY-MM-DD -- based on work from [earliest date] to [latest date]*

## Experience

### Network Automation Engineer -- Verizon

**Automation & Provisioning**
- Bullet here
- Bullet here

**Infrastructure & Platform**
- Bullet here

**Integration & Tooling**
- Bullet here

**Security & Compliance**
- Bullet here

**Observability & Operations**
- Bullet here

## Technical Skills

**Languages:** Python, ...
**Platforms:** OpenShift, GitLab CI/CD, Nautobot, ...
**Tools & Frameworks:** Terraform/OpenTofu, Poetry, Docker, ...
**Vendor Systems:** Cisco, Ericsson, Nokia, Casa, ...
```

Use `*` for list markers, not `-`. Two blank lines between major sections.

## Writing rules

- Write for a hiring manager or recruiter -- outcomes and impact, not implementation details
- Resume action verbs: Designed, Automated, Built, Implemented, Led, Migrated, Integrated, Developed, Streamlined, Optimized, Engineered, Established, Consolidated
- Each bullet: **action verb + what you did + impact/outcome when known**
- No jargon: no file paths, function names, CLI commands, config file names, variable names
- Combine related commits/work into single impactful bullets -- one project spanning weeks should be one strong bullet, not five small ones
- Include approximate timeframes in parentheses where inferable from commit dates (e.g., "Q1 2026", "Jan-Mar 2026")
- Order bullets within each category by impact/significance, most impactful first
- Do not fabricate impact metrics or numbers that aren't supported by the data

## Examples

BAD: "Updated aspn_vpgw.py to handle new cabinet_type field in request payload"
GOOD: "Automated Cisco VPGW provisioning workflows, reducing manual configuration steps for network service requests"

BAD: "Created Terraform modules and refactored .tf files for Nautobot"
GOOD: "Migrated Nautobot infrastructure deployments to Terraform, enabling reproducible and version-controlled provisioning"

BAD: "Added CyberArk integration to nautobot-cyberark plugin"
GOOD: "Built a CyberArk secrets integration plugin for Nautobot, centralizing credential management across network automation tools"

## Wrap-up

Confirm file path, number of repos scanned, number of commits processed, date range covered, and number of accomplishment bullets generated. Tell the user the file is ready for review.
