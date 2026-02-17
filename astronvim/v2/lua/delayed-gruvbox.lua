-- смена темы после запуска vim

-- vim.defer_fn(function()
--   vim.cmd("colorscheme gruvbox")
-- end, 4000)  -- 4000 миллисекунд = 4 секунды

vim.defer_fn(function()
  vim.cmd("colorscheme gruvbox")
end, 4000)  -- 4000 миллисекунд = 4 секунды
