-- ~/.config/nvim/after/plugin/go_run.lua

-- Для всех Go-файлов вешаем локальный <F9>
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    -- если захотите Shift+G или F6, просто добавьте ещё два блока ниже
    vim.keymap.set("n", "`",
      function()
        vim.cmd("silent write")                      -- автосейв
        vim.cmd('TermExec cmd="clear && go run %"')           -- запуск
      end,
      { buffer = true, desc = "Run Go file" }
    )
  end,
})
