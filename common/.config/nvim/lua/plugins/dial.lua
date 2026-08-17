local function dial(increment, g)
  local mode = vim.fn.mode(true)
  local is_visual = mode == "v" or mode == "V" or mode == "\22"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
  return require("dial.map")[func](group)
end

-- Ctrl-a is the tmux prefix. + and - increment instead of moving by line.
return {
  "monaqa/dial.nvim",
  keys = {
    { "<C-a>", false },
    { "<C-x>", false },
    { "g<C-a>", false },
    { "g<C-x>", false },
    {
      "+",
      function()
        return dial(true)
      end,
      expr = true,
      desc = "Increment",
      mode = { "n", "v" },
    },
    {
      "-",
      function()
        return dial(false)
      end,
      expr = true,
      desc = "Decrement",
      mode = { "n", "v" },
    },
  },
}
