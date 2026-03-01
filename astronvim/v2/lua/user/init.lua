return {
  opt = {
    number = true,
    relativenumber = false,
    swapfile = false,
    scrolloff = 7,
    cursorline = true,
    wrap = false,
    ignorecase = true,
    smartcase = true,
  },

  g = {
    gruvbox_contrast_dark = "soft",
    gruvbox_italic_comments = true,
  },

  colorscheme = "gruvbox",

  polish = function()
    vim.cmd("colorscheme gruvbox")
  end,
}
