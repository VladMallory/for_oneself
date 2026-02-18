return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  lazy     = false,
  config   = function()
    require("gruvbox").setup({
      contrast = "soft",
      italic   = { comments = true },
    })
  end,
}

-- return {
--   "vague-theme/vague.nvim",
--   lazy     = false,
--   priority = 1000,
--   config   = function()
--     require("vague").setup({ ... })
--   end,
-- }

-- return {
--   "xero/miasma.nvim",
--   lazy   = false,
--   priority = 1000,
--   config = function()
--     vim.cmd("colorscheme miasma")
--   end,
-- }
