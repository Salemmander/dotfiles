-- Live multi-file diff viewer for reviewing agent edits + which-key group for <leader>a.

local function toggle_diffview()
  local ok, lib = pcall(require, "diffview.lib")
  if ok and lib.get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    opts = {
      watch_index = true,
      enhanced_diff_hl = true,
    },
    keys = {
      { "<leader>av", toggle_diffview, desc = "Toggle Diffview (Agent Edits)" },
      { "<leader>ah", "<cmd>DiffviewFileHistory %<cr>", desc = "File Git History" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "agent", mode = { "n", "v" } },
      },
    },
  },
}
