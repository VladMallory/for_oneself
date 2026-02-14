vim.opt.swapfile = false -- отключить создание swap файлов
vim.opt.scrolloff = 7 -- минимальное количество строк сверху/снизу от курсора
vim.opt.clipboard = "unnamedplus" -- использовать системный буфер обмена
-- Перенос строк
vim.opt.wrap = true -- включить перенос длинных строк
vim.opt.linebreak = true -- переносить по границам слов, а не по символам
vim.opt.breakindent = true -- сохранять отступы при переносе строк
vim.opt.showbreak = "↪ " -- символ в начале перенесённой части строки
vim.opt.breakindentopt = "shift:2,min:40" -- дополнительный отступ для перенесённых строк
