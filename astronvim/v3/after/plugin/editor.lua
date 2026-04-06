local function term_exec(command)
  if vim.fn.exists(":TermExec") == 0 then
    vim.notify("TermExec is unavailable", vim.log.levels.ERROR)
    return
  end

  vim.cmd(("TermExec cmd=%s"):format(vim.fn.string(command)))
end

local function generate_iferr()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local offset = vim.fn.line2byte(row) + col
  local file = vim.fn.expand "%:p"
  local command = "iferr -pos " .. offset .. " < " .. vim.fn.shellescape(file)
  local output = vim.fn.system(command)

  if vim.v.shell_error ~= 0 then
    vim.notify("iferr failed", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
end

local function copy_buffer_to_clipboard()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  vim.cmd('normal! ggVG"+y')
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.notify("Copied buffer to system clipboard", vim.log.levels.INFO)
end

local function clear_file_content()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.notify("Cleared file content", vim.log.levels.INFO)
end

vim.keymap.set("n", "<Leader>2", "<Cmd>AerialToggle<CR>", { desc = "Toggle Aerial", silent = true })
vim.keymap.set("n", "<Leader>3", function() term_exec "go test ./..." end, { desc = "Run Go tests" })
vim.keymap.set("n", "<Leader>4", vim.lsp.buf.rename, { desc = "LSP Rename" })
vim.keymap.set("n", "2", "<Cmd>write<CR>", { desc = "Save file", silent = true })
vim.keymap.set("n", "<Leader>5", generate_iferr, { desc = "Generate if err block" })
vim.keymap.set("n", "<Leader>[", copy_buffer_to_clipboard, { desc = "Copy whole file", silent = true })
vim.keymap.set("n", "89", function()
  local confirm = vim.fn.confirm("Clear all file content?", "&Yes\n&No", 2)
  if confirm == 1 then
    clear_file_content()
  else
    vim.notify("Operation cancelled", vim.log.levels.INFO)
  end
end, { desc = "Clear all file content with confirmation" })
vim.keymap.set("n", "<Leader>89", clear_file_content, { desc = "Clear all file content" })
vim.keymap.set("n", "<Leader>tb", "<Cmd>bd!<CR>", { desc = "Force close buffer", silent = true })

vim.api.nvim_create_user_command("ClearFile", clear_file_content, { desc = "Clear all file content" })
