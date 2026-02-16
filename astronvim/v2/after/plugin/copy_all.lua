vim.keymap.set("n", "<leader>[", function()
  -- Сохраняем текущую позицию курсора
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Выделяем весь текст
  vim.cmd("normal! ggVG\"+y")

  -- Восстанавливаем позицию курсора
  vim.api.nvim_win_set_cursor(0, cursor_pos)

  -- Показываем сообщение
  vim.notify("Весь буфер скопирован в системный буфер обмена!", vim.log.levels.INFO)
end, { desc = "Копировать весь файл", noremap = true, silent = true })
