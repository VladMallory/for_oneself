vim.opt.swapfile = false -- отключить создание swap файлов
vim.opt.scrolloff = 7 -- минимальное количество строк сверху/снизу от курсора
vim.opt.clipboard = "unnamedplus" -- использовать системный буфер обмена
-- Перенос строк
vim.opt.wrap = true -- включить перенос длинных строк
vim.opt.linebreak = true -- переносить по границам слов, а не по символам
vim.opt.breakindent = true -- сохранять отступы при переносе строк
vim.opt.showbreak = "↪ " -- символ в начале перенесённой части строки
vim.opt.breakindentopt = "shift:2,min:40" -- дополнительный отступ для перенесённых строк

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
