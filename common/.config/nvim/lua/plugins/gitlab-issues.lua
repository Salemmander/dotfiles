local function issue_preview(ctx)
  local i = ctx.item
  local assignees = table.concat(i.assignees or {}, ", ")
  local labels = table.concat(i.labels or {}, ", ")
  local lines = {
    "# " .. i.title,
    "",
    "- **State:** " .. (i.state or ""),
    "- **Author:** " .. (i.author or ""),
    "- **Assignees:** " .. (assignees ~= "" and assignees or "none"),
    "- **Labels:** " .. (labels ~= "" and labels or "none"),
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
  ctx.preview:markdown()
end

local function gitlab_issues()
  local result = vim.fn.system("glab issue list -g cnoe-automation -O json --all 2>&1")
  local ok, issues = pcall(vim.json.decode, result)
  if not ok or type(issues) ~= "table" then
    vim.notify("gitlab-issues: " .. result, vim.log.levels.ERROR)
    return
  end

  local items = {}
  for _, issue in ipairs(issues) do
    local assignees = vim.tbl_map(function(a)
      return a.name
    end, issue.assignees or {})
    local labels = vim.tbl_map(function(l)
      return type(l) == "string" and l or l.name
    end, issue.labels or {})
    table.insert(items, {
      text = string.format("#%-5d %s", issue.iid, issue.title),
      title = issue.title,
      state = issue.state,
      author = issue.author and issue.author.name or "",
      assignees = assignees,
      labels = labels,
      created = (issue.created_at or ""):sub(1, 10),
      description = issue.description or "",
      url = issue.web_url or "",
    })
  end

  Snacks.picker({
    title = "GitLab Issues [cnoe-automation]",
    layout = {
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
    },
    items = items,
    format = function(item)
      return { { item.text } }
    end,
    preview = issue_preview,
  })
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>GI", gitlab_issues, desc = "GitLab Issues (cnoe-automation)" },
  },
}
