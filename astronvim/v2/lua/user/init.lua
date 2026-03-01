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

    vim.keymap.set("n", "<leader>5", function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local offset = vim.fn.line2byte(row) + col
      local file = vim.fn.expand("%:p")

      local cmd = "iferr -pos " .. offset .. " < " .. file
      local output = vim.fn.system(cmd)

      if vim.v.shell_error ~= 0 then
        print("iferr failed")
        return
      end

      vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
    end, { desc = "Generate if err block" })
  end,
}
