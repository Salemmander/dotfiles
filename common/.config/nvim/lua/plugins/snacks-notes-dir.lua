local NOTES_DIR = vim.fn.expand("~/notes")

local function toggle_explorer(cwd, position)
  cwd = vim.fs.normalize(cwd)
  for _, picker in ipairs(Snacks.picker.get({ source = "explorer" })) do
    if vim.fs.normalize(picker:cwd()) == cwd then
      picker:close()
      return
    end
  end
  require("snacks.picker.core.picker").new({
    source = "explorer",
    cwd = cwd,
    layout = position and { layout = { position = position } } or nil,
  })
end

local function toggle_root_explorer()
  toggle_explorer(LazyVim.root(), nil)
end

local function toggle_cwd_explorer()
  toggle_explorer(vim.fn.getcwd(), nil)
end

local function toggle_notes_explorer()
  toggle_explorer(NOTES_DIR, "right")
end

return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>e", toggle_root_explorer, desc = "Explorer Snacks (root dir)" },
    { "<leader>fe", toggle_root_explorer, desc = "Explorer Snacks (root dir)" },
    { "<leader>E", toggle_cwd_explorer, desc = "Explorer Snacks (cwd)" },
    { "<leader>fE", toggle_cwd_explorer, desc = "Explorer Snacks (cwd)" },
    { "<leader>N", toggle_notes_explorer, desc = "Notes Explorer" },
  },
}
