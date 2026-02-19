-- ~/.config/nvim/after/plugin/go_run.lua

-- Функция для убийства всех go run процессов
local function kill_go_processes()
  os.execute("pkill -f 'go run' 2>/dev/null || true")
  os.execute("pkill -f 'go-build' 2>/dev/null || true")
end

-- Поиск относительного пути к main.go
local function find_main_relative_path()
  local current_dir = vim.fn.getcwd()
  local handle = io.popen('find "' .. current_dir .. '" -name "main.go" -type f | head -n 1')
  if handle then
    local full_path = handle:read("*a"):gsub("\n", "")
    handle:close()
    if full_path ~= "" then
      -- Получаем относительный путь
      local relative_path = vim.fn.fnamemodify(full_path, ":.")
      return relative_path
    end
  end
  return nil
end

-- Для всех Go-файлов вешаем локальный `
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.keymap.set("n", "`",
      function()
        vim.cmd("silent write")
        kill_go_processes()
        local main_path = find_main_relative_path()
        if main_path then
          vim.cmd('TermExec cmd="clear && go run ' .. main_path .. '"')
        else
          vim.cmd('TermExec cmd="clear && go run ."')
          print("⚠️ main.go not found, running from current dir")
        end
      end,
      { buffer = true, desc = "Kill and run Go file" }
    )
  end,
})
