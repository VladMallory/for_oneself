return {
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      -- Reapply the theme after startup so the user theme wins consistently.
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function() vim.schedule(function() vim.cmd.colorscheme "gruvbox" end) end,
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
      palette_overrides = {},
    },
  },
}
