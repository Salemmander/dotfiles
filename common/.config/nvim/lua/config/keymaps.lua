-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Neovim <-> tmux agent pane bridge (works with `dev` layout or any split running agy/claude)
local function find_agent_pane()
  if not vim.env.TMUX then
    vim.notify("Not inside a tmux session", vim.log.levels.WARN)
    return nil
  end

  local cur = vim.system({ "tmux", "display-message", "-p", "#{pane_id}" }, { text = true }):wait()
  if cur.code ~= 0 then
    return nil
  end
  local current_pane = vim.trim(cur.stdout)

  local list = vim
    .system({ "tmux", "list-panes", "-F", "#{pane_id}\t#{pane_index}\t#{pane_current_command}" }, { text = true })
    :wait()
  if list.code ~= 0 then
    return nil
  end

  local fallback
  for line in (list.stdout or ""):gmatch("[^\r\n]+") do
    local pid, pindex, pcmd = line:match("^([^\t]+)\t([^\t]+)\t(.*)$")
    if pid and pid ~= current_pane then
      if
        pcmd == "agy"
        or pcmd == "antigravity"
        or pcmd == "claude"
        or pcmd == "codex"
        or pcmd == "grok"
        or pcmd:match("^%d+%.%d+")
      then
        return pid
      end
      if pindex == "1" or not fallback then
        fallback = pid
      end
    end
  end

  if not fallback then
    vim.notify("No adjacent tmux pane found for agent", vim.log.levels.WARN)
  end
  return fallback
end

local function send_to_agent(text)
  local target = find_agent_pane()
  if not target then
    return
  end

  local load = vim.system({ "tmux", "load-buffer", "-b", "nvim_agent", "-" }, { stdin = text }):wait()
  if load.code ~= 0 then
    vim.notify("Failed to load tmux buffer", vim.log.levels.ERROR)
    return
  end

  local paste_cmd = { "tmux", "paste-buffer", "-b", "nvim_agent", "-t", target, "-d" }
  if text:find("\n", 1, true) then
    table.insert(paste_cmd, "-p")
  end
  vim.system(paste_cmd):wait()
  vim.system({ "tmux", "select-pane", "-t", target }):wait()
end

local function rel_path()
  local path = vim.fn.expand("%:.")
  if path == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.WARN)
    return nil
  end
  return path
end

local function send_visual_ref()
  local path = rel_path()
  if not path then
    return
  end
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)

  local ref = start_line == end_line and string.format("@%s:%d ", path, start_line)
    or string.format("@%s:%d-%d ", path, start_line, end_line)
  send_to_agent(ref)
end

local function send_diagnostics()
  local path = rel_path()
  if not path then
    return
  end

  local cur_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = cur_line })
  if #diags == 0 then
    diags = vim.diagnostic.get(0)
  end
  if #diags == 0 then
    vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
    return
  end

  local severity_names = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }

  local out = { string.format("Diagnostics in @%s:", path) }
  for _, d in ipairs(diags) do
    local sev = severity_names[d.severity] or "DIAG"
    local src = d.source and (" [" .. d.source .. "]") or ""
    table.insert(out, string.format("- L%d (%s%s): %s", d.lnum + 1, sev, src, d.message:gsub("\n", " ")))
  end
  table.insert(out, "")
  send_to_agent(table.concat(out, "\n"))
end

vim.keymap.set("n", "<leader>af", function()
  local path = rel_path()
  if path then
    send_to_agent("@" .. path .. " ")
  end
end, { desc = "Send File Ref to Agent" })

vim.keymap.set("n", "<leader>al", function()
  local path = rel_path()
  if path then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    send_to_agent(string.format("@%s:%d ", path, line))
  end
end, { desc = "Send File:Line to Agent" })

vim.keymap.set("v", "<leader>as", send_visual_ref, { desc = "Send Selection Ref to Agent" })

vim.keymap.set("n", "<leader>ad", send_diagnostics, { desc = "Send Diagnostics to Agent" })
