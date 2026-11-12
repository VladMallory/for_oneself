-- Ширина таба в Go — 4 колонки.
-- На содержимое файла это не влияет: gofmt всё равно пишет табы,
-- меняется только отображение. noexpandtab/softtabstop=0/shiftwidth=0
-- уже ставит ftplugin/go.vim, поэтому здесь достаточно tabstop.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_indent = {
        {
          event = "FileType",
          pattern = "go",
          callback = function(args)
            local buf = args.buf
            vim.bo[buf].expandtab = false
            vim.bo[buf].softtabstop = 0
            vim.bo[buf].shiftwidth = 0
            vim.bo[buf].tabstop = 4
          end,
        },
      },
    },
  },
}
