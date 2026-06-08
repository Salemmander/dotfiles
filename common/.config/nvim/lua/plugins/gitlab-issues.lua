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
  local cmd = { "glab", "issue", "list", "-g", "cnoe-automation", "-O", "json", "--all" }
  vim.system(cmd, { text = true }, function(out)
    vim.schedule(function()
      local ok, issues = pcall(vim.json.decode, out.stdout)
      if not ok or type(issues) ~= "table" then
        vim.notify("gitlab-issues: " .. (out.stderr or out.stdout or ""), vim.log.levels.ERROR)
        return
      end

      -- Returns a comma-separated string of assignee display names
      local function get_assignees(issue)
        return table.concat(
          vim.tbl_map(function(a)
            return a.name
          end, issue.assignees or {}),
          ", "
        )
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
      -- Flattens the fields we care about so the preview and display don't need to navigate nested tables.
      local function make_item(issue)
        return {
          text = string.format("#%-5d %s", issue.iid, issue.title),
          title = issue.title,
          state = issue.state,
          author = issue.author and issue.author.name or "",
          assignees = get_assignees(issue),
          labels = get_labels(issue),
          created = (issue.created_at or ""):sub(1, 10),
          description = issue.description or "",
          url = issue.web_url or "",
        }
      end

      local items = {}
      for _, issue in ipairs(issues) do
        table.insert(items, make_item(issue))
      end

      Snacks.picker({
        title = "GitLab Issues [cnoe-automation]",
        layout = LAYOUT,
        items = items,
        format = function(item)
          return { { item.text } }
        end,
        preview = issue_preview,
      })
    end)
  end)
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>GI", gitlab_issues, desc = "GitLab Issues (cnoe-automation)" },
  },
}
