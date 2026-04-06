-- ~/.config/nvim/after/plugin/go_run.lua

-- Функция для убийства всех go run процессов
local function kill_go_processes()
  -- Убиваем все go run процессы (macOS совместимая версия)
  os.execute("pkill -f 'go run' 2>/dev/null || true")
  print("🔥 Killed all 'go run' processes")
end

-- Функция для закрытия терминального буфера
local function close_terminal()
  -- Ищем и закрываем терминальные буферы
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buf_type == 'terminal' then
        -- Проверяем, есть ли окно с этим буфером
        local wins = vim.fn.win_findbuf(buf)
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end
        -- Удаляем буфер
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
  print("🗑️ Closed terminal")
end

-- Для всех Go-файлов вешаем локальную клавишу для закрытия терминала
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    -- Остановка Go программы и закрытие терминала
    vim.keymap.set("n", "1",
      function()
        kill_go_processes()
        vim.schedule(function()
          close_terminal()
        end)
      end,
      { buffer = true, desc = "Kill Go process and close terminal" }
    )
  end,
})

-- Команда для принудительной очистки всех Go процессов и терминалов
vim.api.nvim_create_user_command("GoKillAll", function()
  kill_go_processes()
  close_terminal()
  print("🔥 Killed all Go processes and closed terminals")
end, { desc = "Kill all Go processes and close terminals" })

-- Альтернативная команда только для закрытия терминалов
vim.api.nvim_create_user_command("GoCloseTerminal", function()
  close_terminal()
end, { desc = "Close all terminal buffers" })

-- Дополнительная команда для отладки процессов на macOS
vim.api.nvim_create_user_command("GoDebug", function()
  print("=== Go Process Debug Info ===")
  
  -- Показываем все go процессы
  local handle = io.popen("ps aux | grep '[g]o run' 2>/dev/null || echo 'No go run processes found'")
  if handle then
    local result = handle:read("*a")
    handle:close()
    print("Active go run processes:")
    print(result)
  end
  
  -- Показываем терминальные буферы
  print("\nTerminal buffers:")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buf_type == 'terminal' then
        local buf_name = vim.api.nvim_buf_get_name(buf)
        print(string.format("Buffer %d: %s", buf, buf_name))
      end
    end
  end
end, { desc = "Debug Go processes and terminals" })
