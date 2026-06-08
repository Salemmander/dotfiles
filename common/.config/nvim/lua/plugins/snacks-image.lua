return {
  "folke/snacks.nvim",
  opts = {
    -- snacks.image uses the Kitty Graphics Protocol. In Ghostty inside tmux it
    -- can leak PNG bytes into Neovim buffers when passthrough is enabled.
    image = { enabled = vim.env.TMUX == nil },
  },
}
