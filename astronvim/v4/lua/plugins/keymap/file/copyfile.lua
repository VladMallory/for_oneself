-- space + [ — копирует весь буфер в системный буфер обмена
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>["] = {
          function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.cmd "silent! %yank +"
            vim.api.nvim_win_set_cursor(0, cursor)
          end,
          desc = "Copy whole file to clipboard",
        },
      },
    },
  },
}
