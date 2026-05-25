-- CUDA + custom host compiler support for clangd
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/opt/cuda/bin/nvcc,/usr/bin/g++-15,/usr/bin/g++",
          },
        },
      },
    },
  },
}
