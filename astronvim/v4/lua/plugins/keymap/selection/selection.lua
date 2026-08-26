-- Инкрементальное выделение по синтаксическому дереву (tree-sitter):
-- "9" — выделить узел под курсором, ещё раз — расширить на родительский узел,
-- "8" — уменьшить выделение обратно.
return {
  {
    "MeanderingProgrammer/treesitter-modules.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "9",
          node_incremental = "9",
          scope_incremental = false,
          node_decremental = "8",
        },
      },
    },
  },
}
