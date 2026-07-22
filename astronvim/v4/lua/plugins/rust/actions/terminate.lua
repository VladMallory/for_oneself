-- Клавиша 1 в rust-файлах: убивает cargo run и закрывает все терминалы.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      rust_terminate = {
        {
          event = "FileType",
          pattern = "rust",
          callback = function()
            local function kill_cargo_processes() vim.fn.system "pkill -f 'cargo run'" end

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

            vim.keymap.set("n", "1", function()
              kill_cargo_processes()
              vim.schedule(close_terminal)
            end, { buffer = true, desc = "Kill cargo process and close terminal" })
          end,
        },
      },
    },
  },
}
