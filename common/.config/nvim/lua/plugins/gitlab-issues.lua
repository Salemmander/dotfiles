-- ============================================================
-- Layout: vertical split, list on top, preview on bottom
-- ============================================================
local LAYOUT = {
  layout = {
    box = "vertical",
    width = 0.8,
    height = 0.9,
    border = true,
    title = "{title} {live} {flags}",
    title_pos = "center",
    { win = "input", height = 1, border = "bottom" },
    { win = "list", border = "none" },
    { win = "preview", title = "{preview}", height = 0.7, border = "top" },
  },
}

-- ============================================================
-- Preview: renders issue fields as markdown in the preview pane
-- ============================================================
local function issue_preview(ctx)
  local i = ctx.item
  local lines = {
    "# " .. i.title,
    "",
    "- **State:** " .. (i.state or ""),
    "- **Author:** " .. (i.author or ""),
    "- **Assignees:** " .. (i.assignees ~= "" and i.assignees or "none"),
    "- **Labels:** " .. (i.labels ~= "" and i.labels or "none"),
    "- **Created:** " .. (i.created or ""),
    "- **URL:** " .. (i.url or ""),
    "",
    "---",
    "",
  }
  for _, line in ipairs(vim.split(i.description or "", "\n")) do
    table.insert(lines, line)
  end
  ctx.preview:reset()
  ctx.preview:set_lines(lines)
  require("snacks.picker.util.markdown").render(ctx.preview.win.buf, { images = false })
end

-- ============================================================
-- Picker: fetches all open group issues and opens the picker
-- ============================================================
local function gitlab_issues()
  -- Closure state
  local all_items = {}
  local assigned_only = false
  local username = nil

  -- Title reflects the current assignee filter
  local function title_for()
    if assigned_only then
      return "GitLab Issues [cnoe-automation] (mine)"
    end
    return "GitLab Issues [cnoe-automation]"
  end

  -- Returns a filtered or unfiltered view of all_items
  local function compute_items()
    if not assigned_only then
      return all_items
    end
    return vim.tbl_filter(function(item)
      return vim.tbl_contains(item.assignee_usernames, username)
    end, all_items)
  end

  -- Returns a comma-separated string of assignee display names (for the preview)
  local function get_assignees(issue)
    return table.concat(
      vim.tbl_map(function(a)
        return a.name
      end, issue.assignees or {}),
      ", "
    )
  end

  -- Returns a list of assignee usernames (for the assignee filter)
  local function get_assignee_usernames(issue)
    return vim.tbl_map(function(a)
      return a.username
    end, issue.assignees or {})
  end

  -- Returns a comma-separated string of label names.
  -- Labels can come back as either strings or objects depending on the API version.
  local function get_labels(issue)
    return table.concat(
      vim.tbl_map(function(l)
        return type(l) == "string" and l or l.name
      end, issue.labels or {}),
      ", "
    )
  end

  -- Builds a picker item from a raw issue object.
  -- Flattens the fields we care about so the preview and filters don't navigate nested tables.
  local function make_item(issue)
    local repo = (issue.web_url or ""):match("gitlab%.verizon%.com/(.-)/-/issues")
    return {
      text = string.format("#%-5d %s", issue.iid, issue.title),
      iid = issue.iid,
      repo = repo or "",
      title = issue.title,
      state = issue.state,
      author = issue.author and issue.author.name or "",
      assignees = get_assignees(issue),
      assignee_usernames = get_assignee_usernames(issue),
      labels = get_labels(issue),
      created = (issue.created_at or ""):sub(1, 10),
      description = issue.description or "",
      url = issue.web_url or "",
    }
  end

  -- Opens the picker once both async fetches (user + issues) have completed.
  -- Using a simple pending counter; math.huge acts as a sentinel to suppress opening on error.
  local pending = 2

  local function try_open()
    if pending > 0 then
      return
    end
    Snacks.picker({
      title = title_for(),
      layout = LAYOUT,
      items = compute_items(),
      format = function(item)
        return { { item.text } }
      end,
      preview = issue_preview,
      actions = {
        view_issue = function(picker, item)
          vim.ui.open(item.url)
        end,
        toggle_assignee = function(picker)
          if not username then
            vim.notify("gitlab-issues: GitLab username unavailable; assignee filter has no effect", vim.log.levels.WARN)
            return
          end
          assigned_only = not assigned_only
          picker.opts.items = compute_items()
          picker.title = title_for()
          picker:find({ refresh = true })
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-o>"] = { "view_issue", mode = { "i", "n" } },
            ["<C-f>"] = { "toggle_assignee", mode = { "i", "n" } },
          },
        },
      },
    })
  end

  -- Fetch the current GitLab username (needed for the assignee filter).
  -- Non-fatal: if it fails the picker still opens, but <C-a> will warn and no-op.
  vim.system({ "glab", "api", "user", "--output", "json" }, { text = true }, function(out)
    vim.schedule(function()
      local ok, user = pcall(vim.json.decode, out.stdout)
      if ok and type(user) == "table" and type(user.username) == "string" then
        username = user.username
      else
        vim.notify("gitlab-issues: could not resolve GitLab username (glab api user failed)", vim.log.levels.WARN)
      end
      pending = pending - 1
      try_open()
    end)
  end)

  -- Fetch all open issues in the cnoe-automation group.
  -- Fatal: if this fails, suppress the picker by pinning pending to math.huge.
  local cmd = { "glab", "issue", "list", "-g", "cnoe-automation", "-O", "json", "--all" }
  vim.system(cmd, { text = true }, function(out)
    vim.schedule(function()
      local ok, issues = pcall(vim.json.decode, out.stdout)
      if not ok or type(issues) ~= "table" then
        vim.notify("gitlab-issues: " .. (out.stderr or out.stdout or ""), vim.log.levels.ERROR)
        pending = math.huge -- sentinel: never open
        return
      end
      for _, issue in ipairs(issues) do
        table.insert(all_items, make_item(issue))
      end
      pending = pending - 1
      try_open()
    end)
  end)
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>GI", gitlab_issues, desc = "GitLab Issues (cnoe-automation)" },
  },
}
