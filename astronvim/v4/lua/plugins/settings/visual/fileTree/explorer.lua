-- Скрываем .DS_Store в neo-tree (space + e).
-- macOS создаёт эти файлы в каждой папке — мешают навигации.
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
    opts.filesystem.filtered_items.never_show = { ".DS_Store" }
    return opts
  end,
}
