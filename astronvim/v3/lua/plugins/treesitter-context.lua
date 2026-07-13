---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "BufReadPost",
  opts = {
    enable = true,
    max_lines = 5,
    min_window_height = 0,
    line_numbers = true,
    multiline_threshold = 3,
    trim_scope = "outer",
    mode = "cursor",
  },
  config = function(_, opts)
    require("treesitter-context").setup(opts)
    vim.api.nvim_set_hl(0, "TreesitterContext", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { link = "LineNr" })
  end,
}
