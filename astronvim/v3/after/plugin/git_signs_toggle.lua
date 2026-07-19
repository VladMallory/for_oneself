vim.keymap.set("n", "<Leader>gv", function()
  require("gitsigns").toggle_signs()
end, { desc = "Toggle Git signs", silent = true })
