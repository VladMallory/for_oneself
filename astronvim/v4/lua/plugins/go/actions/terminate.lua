-- Клавиша 1 в go-файлах: убивает фоновые процессы go run и закрывает все терминалы.
-- Команда :GoKillAll — то же самое из любой точки.
-- vim.schedule нужен, чтобы терминал успел освободиться после kill.
local function kill_go_processes()
  vim.fn.system "pkill -f 'go run'"
  vim.fn.system "pkill -f 'go-build'"
end

local function close_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    commands = {
      GoKillAll = {
        function()
          kill_go_processes()
          vim.schedule(close_terminal)
        end,
        desc = "Kill all Go processes and close terminals",
      },
    },
    autocmds = {
      go_terminate = {
        {
          event = "FileType",
          pattern = "go",
          callback = function()
            vim.keymap.set("n", "1", function()
              kill_go_processes()
              vim.schedule(close_terminal)
            end, { buffer = true, desc = "Kill Go process and close terminal" })
          end,
        },
      },
    },
  },
}
