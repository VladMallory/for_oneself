-- ~/.config/nvim/after/plugin/clear_file.lua
-- Скрипт для удаления всего содержимого файла при нажатии 89

-- Функция для очистки всего содержимого файла
local function clear_file_content()
  -- Переходим в начало файла (gg)
  vim.cmd("normal! gg")
  
  -- Удаляем все строки (500dd - с запасом)
  vim.cmd("normal! 500dd")
  
  print("🗑️ File content cleared")
end

-- Создаем глобальную команду для очистки файла
vim.api.nvim_create_user_command("ClearFile", function()
  clear_file_content()
end, { desc = "Clear all file content" })

-- Создаем маппинг для клавиш 89
vim.keymap.set("n", "89", 
  function()
    -- Запрашиваем подтверждение перед удалением
    local confirm = vim.fn.confirm("Clear all file content?", "&Yes\n&No", 2)
    if confirm == 1 then
      clear_file_content()
    else
      print("Operation cancelled")
    end
  end,
  { desc = "Clear all file content with confirmation" }
)

-- Альтернативный маппинг без подтверждения (если нужен)
vim.keymap.set("n", "<leader>89", 
  function()
    clear_file_content()
  end,
  { desc = "Clear all file content (no confirmation)" }
)


