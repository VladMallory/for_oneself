local function kill_cargo_processes()
  os.execute("pkill -f 'cargo run' 2>/dev/null || true")
end

local function close_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buf_type == 'terminal' then
        local wins = vim.fn.win_findbuf(buf)
        for _, win in ipairs(wins) do
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
  print("🗑️ Closed terminal")
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set("n", "`",
      function()
        vim.cmd("silent write")
        kill_cargo_processes()
        vim.cmd('TermExec cmd="clear && cargo run"')
      end,
      { buffer = true, desc = "Kill and run Rust project" }
    )
    vim.keymap.set("n", "1",
      function()
        kill_cargo_processes()
        vim.schedule(function()
          close_terminal()
        end)
      end,
      { buffer = true, desc = "Kill cargo process and close terminal" }
    )
  end,
})
