-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Machine-local Omarchy helper. Absent on other machines; do not vendor it here.
local ok, remote_clipboard = pcall(require, "config.remote_clipboard")
if ok then
  remote_clipboard.setup()
end
vim.opt.relativenumber = true
vim.opt.smoothscroll = true
vim.opt.autoread = true
vim.opt.updatetime = 500
