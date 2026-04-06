local function term_exec(command)
  if vim.fn.exists(":TermExec") == 0 then
    vim.notify("TermExec is unavailable", vim.log.levels.ERROR)
    return
  end

  vim.cmd(("TermExec cmd=%s"):format(vim.fn.string(command)))
end

local function close_terminal_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  vim.notify("Closed terminal buffers", vim.log.levels.INFO)
end

local function kill_cargo_processes(message)
  os.execute(("pkill -f %s 2>/dev/null || true"):format(vim.fn.shellescape("cargo run")))
  if message then vim.notify(message, vim.log.levels.INFO) end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    vim.keymap.set("n", "`", function()
      vim.cmd "silent write"
      kill_cargo_processes()
      term_exec "clear && cargo run"
    end, { buffer = args.buf, desc = "Kill and run Rust project" })

    vim.keymap.set("n", "1", function()
      kill_cargo_processes("Killed all cargo run processes")
      vim.schedule(close_terminal_buffers)
    end, { buffer = args.buf, desc = "Kill cargo process and close terminal" })
  end,
})
