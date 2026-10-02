-- Клавиша 1 в zig-файлах: убивает фоновые процессы zig и закрывает все терминалы.
-- Команда :ZigKillAll — то же самое из любой точки.
-- vim.schedule нужен, чтобы терминал успел освободиться после kill.
local function kill_zig_processes()
  vim.fn.system "pkill -f 'zig build'"
  vim.fn.system "pkill -f 'zig run'"
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
      ZigKillAll = {
        function()
          kill_zig_processes()
          vim.schedule(close_terminal)
        end,
        desc = "Kill all Zig processes and close terminals",
      },
    },
    autocmds = {
      zig_terminate = {
        {
          event = "FileType",
          pattern = "zig",
          callback = function()
            vim.keymap.set("n", "1", function()
              kill_zig_processes()
              vim.schedule(close_terminal)
            end, { buffer = true, desc = "Kill Zig process and close terminal" })
          end,
        },
      },
    },
  },
}
