local KEYS = {
  { key = "<C-o>", action = "view_issue", desc = "open" },
  { key = "<C-e>", action = "assign_self", desc = "assign" },
  { key = "<C-f>", action = "toggle_assignee", desc = "mine" },
  { key = "<C-g>", action = "toggle_scope", desc = "scope" },
  { key = "<C-s>", action = "toggle_state", desc = "state" },
  { key = "<C-r>", action = "pick_repo", desc = "repo" },
  { key = "<C-t>", action = "create_issue", desc = "new" },
  { key = "<C-x>", action = "close_reopen", desc = "close/open" },
}

local FOOTER = table.concat(
  vim.tbl_map(function(k)
    local letter = k.key:match("<C%-(.-)>")
    return "^" .. letter .. " " .. k.desc
  end, KEYS),
  "  "
)

-- ============================================================
-- Layout: vertical split, list on top, preview on bottom
-- ============================================================
local LAYOUT = {
  layout = {
    box = "vertical",
    width = 0.8,
    height = 0.7,
    border = true,
    title = "{title} {live} {flags}",
    title_pos = "center",
    footer = FOOTER,
    footer_pos = "center",
    { win = "input", height = 1, border = "bottom" },
    { win = "list", border = "none" },
    { win = "preview", title = "{preview}", height = 0.7, border = "top" },
  },
}

local GROUP = "cnoe-automation"

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
-- Returns items matching all supplied criteria.
-- A nil field means "no constraint on that dimension", so filter_items(items, {})
-- returns everything. Adding a new filter dimension is one more `if` here and one
-- more field in the opts table passed by compute_items().
local function filter_items(items, opts)
  return vim.tbl_filter(function(item)
    if opts.repo and item.repo ~= opts.repo then
      return false
    end
    if opts.assignee and not vim.tbl_contains(item.assignee_usernames, opts.assignee) then
      return false
    end
    if opts.state and item.state ~= opts.state then
      return false
    end
    return true
  end, items)
end

-- Session-level cache for the cnoe-automation project list (nil = not yet fetched).
local repo_cache = nil

-- Fetches all projects in cnoe-automation, handling pagination.
-- Returns from cache on subsequent calls within the same Neovim session.
-- Calls callback(repos) on success or callback(nil, err_msg) on failure.
local function fetch_all_repos(callback)
  if repo_cache then
    callback(repo_cache)
    return
  end
  local accumulated = {}
  local function fetch_page(page)
    local url = "groups/" .. GROUP .. "/projects?include_subgroups=true&per_page=100&page=" .. page
    vim.system({ "glab", "api", url }, { text = true }, function(out)
      vim.schedule(function()
        local ok, projects = pcall(vim.json.decode, out.stdout)
        if not ok or type(projects) ~= "table" then
          callback(nil, out.stderr or "failed to fetch repos")
          return
        end
        for _, p in ipairs(projects) do
          if type(p.path_with_namespace) == "string" then
            table.insert(accumulated, p.path_with_namespace)
          end
        end
        if #projects == 100 then
          fetch_page(page + 1)
        else
          repo_cache = accumulated
          callback(accumulated)
        end
      end)
    end)
  end
  fetch_page(1)
end

-- Runs the repo → title → description → create flow.
-- detected_repo is placed first in the list if set.
-- on_success() is called after a successful create.
local function run_create_issue(detected_repo, on_success)
  if not repo_cache then
    vim.notify("Fetching repos...", vim.log.levels.INFO)
  end
  fetch_all_repos(function(all_repos, err)
    if err then
      vim.notify("gitlab-issues: " .. err, vim.log.levels.ERROR)
      return
    end
    table.sort(all_repos)
    if detected_repo then
      for i, r in ipairs(all_repos) do
        if r == detected_repo then
          table.remove(all_repos, i)
          break
        end
      end
      table.insert(all_repos, 1, detected_repo)
    end
    if #all_repos == 0 then
      vim.notify("gitlab-issues: no repos found in " .. GROUP, vim.log.levels.WARN)
      return
    end

    local chosen_repo, chosen_title
    local on_desc, on_title, on_repo

    on_desc = function(desc)
      local cmd = {
        "glab",
        "issue",
        "create",
        "-R",
        chosen_repo,
        "--title",
        chosen_title,
        "--description",
        desc or "",
      }
      vim.notify("Creating issue in " .. chosen_repo .. "...", vim.log.levels.INFO)
      vim.system(cmd, { text = true }, function(out)
        vim.schedule(function()
          if out.code ~= 0 then
            vim.notify("gitlab-issues: " .. (out.stderr or "create failed"), vim.log.levels.ERROR)
            return
          end
          vim.notify("Issue created: " .. vim.trim(out.stdout), vim.log.levels.INFO)
          on_success()
        end)
      end)
    end

    on_title = function(title)
      if not title or vim.trim(title) == "" then
        return
      end
      chosen_title = title
      vim.ui.input({ prompt = "Description (optional): " }, on_desc)
    end

    on_repo = function(repo)
      if not repo then
        return
      end
      chosen_repo = repo
      vim.ui.input({ prompt = "Title: " }, on_title)
    end

    vim.ui.select(all_repos, { prompt = "Create issue in repo: " }, on_repo)
  end)
end

local function gitlab_issues(opts)
  opts = opts or {}
  -- Detect current repo synchronously (local git call, no async needed)
  local origin = vim.trim(vim.fn.system("git remote get-url origin 2>/dev/null"))
  local m = origin:match("gitlab%.verizon%.com[:/](.+)%.git$")
  local detected_repo = (m and vim.startswith(m, GROUP .. "/")) and m or nil

  -- Closure state: nil = no filter, string = filter to that repo
  local all_items = {}
  local assigned_only = false
  local repo_filter = nil
  local state_filter = opts.state or nil -- nil = all, "opened" = open only, "closed" = closed only
  local username = nil

  -- Title reflects active filters
  local function title_for()
    local scope = repo_filter and (repo_filter:match("[^/]+$") or repo_filter) or GROUP
    local assignee = assigned_only and " (mine)" or ""
    local state = state_filter and " [" .. state_filter .. "]" or ""
    return "GitLab Issues [" .. scope .. "]" .. assignee .. state
  end

  -- Maps current state to filter criteria and delegates to filter_items
  local function compute_items()
    return filter_items(all_items, {
      repo = repo_filter,
      assignee = assigned_only and username or nil,
      state = state_filter,
    })
  end

  -- Applies current filter state to the picker (called after any state change)
  local function apply_filter(picker)
    picker.opts.items = compute_items()
    picker.title = title_for()
    picker:find({ refresh = true })
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
    local repo = issue.references and (issue.references.full or ""):match("(.+)#%d+") or ""
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
        if item.state == "closed" then
          return { { "✓ ", "DiagnosticInfo" }, { item.text, "Comment" } }
        end
        return { { "○ ", "DiagnosticOk" }, { item.text } }
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
          apply_filter(picker)
        end,
        toggle_scope = function(picker)
          if not detected_repo then
            vim.notify("gitlab-issues: not in a " .. GROUP .. " repo; scope filter unavailable", vim.log.levels.WARN)
            return
          end
          if repo_filter == detected_repo then
            repo_filter = nil
          else
            repo_filter = detected_repo
          end
          apply_filter(picker)
        end,
        toggle_state = function(picker)
          if state_filter == nil then
            state_filter = "opened"
          elseif state_filter == "opened" then
            state_filter = "closed"
          else
            state_filter = nil
          end
          apply_filter(picker)
        end,
        assign_self = function(picker, item)
          if not username then
            vim.notify("gitlab-issues: GitLab username unavailable", vim.log.levels.WARN)
            return
          end
          local is_assigned = vim.tbl_contains(item.assignee_usernames, username)
          local prefix = is_assigned and "-" or "+"
          local action_label = is_assigned and "Unassigned from" or "Assigned to"
          local pending_label = is_assigned and "Unassigning from" or "Assigning to"
          vim.notify(pending_label .. " #" .. item.iid .. ": " .. item.title, vim.log.levels.INFO)
          local cmd =
            { "glab", "issue", "update", tostring(item.iid), "-R", item.repo, "--assignee", prefix .. username }
          vim.system(cmd, { text = true }, function(out)
            vim.schedule(function()
              if out.code ~= 0 then
                vim.notify("gitlab-issues: " .. (out.stderr or "update failed"), vim.log.levels.ERROR)
                return
              end
              local encoded_repo = item.repo:gsub("/", "%%2F")
              local api_path = "projects/" .. encoded_repo .. "/issues/" .. tostring(item.iid)
              vim.system({ "glab", "api", api_path }, { text = true }, function(fetch_out)
                vim.schedule(function()
                  local ok, updated = pcall(vim.json.decode, fetch_out.stdout)
                  if ok and type(updated) == "table" then
                    local new_item = make_item(updated)
                    for idx, i in ipairs(all_items) do
                      if i.iid == item.iid and i.repo == item.repo then
                        all_items[idx] = new_item
                        break
                      end
                    end
                  end
                  vim.notify(action_label .. " #" .. item.iid .. ": " .. item.title, vim.log.levels.INFO)
                  apply_filter(picker)
                end)
              end)
            end)
          end)
        end,
        close_reopen = function(picker, item)
          local is_open = item.state == "opened"
          local action_word = is_open and "Close" or "Reopen"
          local cmd_verb = is_open and "close" or "reopen"
          local done_label = is_open and "Closed" or "Reopened"
          vim.ui.select({ "No", "Yes" }, {
            prompt = action_word .. " #" .. item.iid .. ": " .. item.title .. "?",
          }, function(choice)
            if choice ~= "Yes" then
              return
            end
            vim.notify(action_word .. "ing #" .. item.iid .. "...", vim.log.levels.INFO)
            local cmd = { "glab", "issue", cmd_verb, tostring(item.iid), "-R", item.repo }
            vim.system(cmd, { text = true }, function(out)
              vim.schedule(function()
                if out.code ~= 0 then
                  vim.notify("gitlab-issues: " .. (out.stderr or cmd_verb .. " failed"), vim.log.levels.ERROR)
                  return
                end
                local encoded_repo = item.repo:gsub("/", "%%2F")
                local api_path = "projects/" .. encoded_repo .. "/issues/" .. tostring(item.iid)
                vim.system({ "glab", "api", api_path }, { text = true }, function(fetch_out)
                  vim.schedule(function()
                    local ok, updated = pcall(vim.json.decode, fetch_out.stdout)
                    if ok and type(updated) == "table" then
                      local new_item = make_item(updated)
                      for idx, i in ipairs(all_items) do
                        if i.iid == item.iid and i.repo == item.repo then
                          all_items[idx] = new_item
                          break
                        end
                      end
                    end
                    vim.notify(done_label .. " #" .. item.iid .. ": " .. item.title, vim.log.levels.INFO)
                    apply_filter(picker)
                  end)
                end)
              end)
            end)
          end)
        end,
        create_issue = function(picker)
          run_create_issue(detected_repo, function()
            local fetch_cmd = { "glab", "issue", "list", "-g", GROUP, "-O", "json", "--all" }
            vim.system(fetch_cmd, { text = true }, function(fetch_out)
              vim.schedule(function()
                local ok, issues = pcall(vim.json.decode, fetch_out.stdout)
                if ok and type(issues) == "table" then
                  all_items = {}
                  for _, issue in ipairs(issues) do
                    table.insert(all_items, make_item(issue))
                  end
                  apply_filter(picker)
                end
              end)
            end)
          end)
        end,
        pick_repo = function(picker)
          local seen = {}
          local repos = {}
          for _, item in ipairs(all_items) do
            if item.repo ~= "" and not seen[item.repo] then
              seen[item.repo] = true
              table.insert(repos, item.repo)
            end
          end
          table.sort(repos)
          table.insert(repos, 1, "All repos")
          vim.ui.select(repos, { prompt = "Filter by repo: " }, function(choice)
            if not choice then
              return
            end
            if choice == "All repos" then
              repo_filter = nil
            else
              repo_filter = choice
            end
            apply_filter(picker)
          end)
        end,
      },
      win = {
        input = {
          keys = (function()
            local k = {}
            for _, entry in ipairs(KEYS) do
              k[entry.key] = { entry.action, mode = { "i", "n" } }
            end
            return k
          end)(),
        },
      },
    })
    if not repo_cache then
      fetch_all_repos(function() end)
    end
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
  local cmd = { "glab", "issue", "list", "-g", GROUP, "-O", "json", "--all" }
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

local function gitlab_create_issue()
  local origin = vim.trim(vim.fn.system("git remote get-url origin 2>/dev/null"))
  local m = origin:match("gitlab%.verizon%.com[:/](.+)%.git$")
  local detected_repo = (m and vim.startswith(m, GROUP .. "/")) and m or nil
  run_create_issue(detected_repo, function() end)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>GI", gitlab_issues, desc = "GitLab Issues - all" },
      {
        "<leader>Gi",
        function()
          gitlab_issues({ state = "opened" })
        end,
        desc = "GitLab Issues - open",
      },
      { "<leader>GC", gitlab_create_issue, desc = "GitLab Create Issue" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>G", group = "GitLab", icon = { icon = "󰮠", color = "orange" } },
      },
    },
  },
}
