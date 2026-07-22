-- Тема gruvbox.
-- lazy = false обязательно для colorscheme — иначе тема не применится.
-- init + VimEnter с vim.schedule — переприменяет тему после загрузки всего UI,
-- чтобы пользовательская тема победила дефолтную astrodark.
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(function() vim.cmd.colorscheme "gruvbox" end)
        end,
      })
    end,
    opts = {
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = false,
        comments = true,
        operators = false,
        folds = true,
      },
      contrast = "soft",
    },
  },
}
