-- Live multi-file diff viewer for reviewing agent edits + which-key group for <leader>a.

local function toggle_diffview(cmd)
  local ok, lib = pcall(require, "diffview.lib")
  if ok and lib.get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd(cmd)
  end
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    opts = {
      watch_index = true,
      enhanced_diff_hl = true,
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    },
    keys = {
      {
        "<leader>av",
        function()
          toggle_diffview("DiffviewOpen")
        end,
        desc = "Toggle Diffview (Agent Edits)",
      },
      {
        "<leader>ah",
        function()
          toggle_diffview("DiffviewFileHistory %")
        end,
        desc = "Toggle File Git History",
      },
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
