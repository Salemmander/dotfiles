return {
  {
    "Civitasv/cmake-tools.nvim",
    keys = {
      { "<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "Generate" },
      { "<leader>mb", "<cmd>CMakeBuild<cr>", desc = "Build" },
      { "<leader>mr", "<cmd>CMakeRun<cr>", desc = "Run" },
      { "<leader>md", "<cmd>CMakeDebug<cr>", desc = "Debug" },
      { "<leader>mf", "<cmd>CMakeDebugCurrentFile<cr>", desc = "Debug Current File" },
      { "<leader>mt", "<cmd>CMakeSelectLaunchTarget<cr>", desc = "Select Launch Target" },
      { "<leader>mT", "<cmd>CMakeSelectBuildTarget<cr>", desc = "Select Build Target" },
      { "<leader>my", "<cmd>CMakeSelectBuildType<cr>", desc = "Select Build Type" },
      { "<leader>ma", "<cmd>CMakeLaunchArgs<cr>", desc = "Launch Args" },
      { "<leader>mo", "<cmd>CMakeOpenExecutor<cr>", desc = "Open Output" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>m", group = "cmake" },
      },
    },
  },
}
