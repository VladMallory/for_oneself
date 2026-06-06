return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
    opts.filesystem.filtered_items.never_show = { ".DS_Store" }
    opts.log_level = vim.log.levels.WARN
    return opts
  end,
}
