-- ]] в go-файлах: запускает `go test ./...`.
-- Вывод открывается в новой вкладке на весь экран, закрыть — q (или Esc).
local function open_output()
  vim.cmd "tabnew"
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  -- Подсветка как у bash: строка с командой и вывод выглядят «терминально».
  vim.bo[buf].filetype = "bash"
  vim.bo[buf].syntax = "bash"
  vim.keymap.set("n", "q", "<Cmd>tabclose<CR>", { buffer = buf, desc = "Close Go test output" })
  vim.keymap.set("n", "<Esc>", "<Cmd>tabclose<CR>", { buffer = buf, desc = "Close Go test output" })
  return buf
end

local function set_lines(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function go_test()
  -- Корень модуля: папка с go.mod, иначе текущая директория.
  local root = vim.fs.root(0, "go.mod") or vim.fn.getcwd()
  local cmd = { "go", "test", "./..." }
  local title = "$ " .. table.concat(cmd, " ")

  local buf = open_output()
  set_lines(buf, { title, "", "Running..." })

  local ok, err = pcall(vim.system, cmd, { cwd = root, text = true }, function(res)
    vim.schedule(function()
      local lines = { title, "" }
      local out = (res.stdout or "") .. (res.stderr or "")
      out = out:gsub("^%s*\n", ""):gsub("\n%s*$", "")
      if out ~= "" then vim.list_extend(lines, vim.split(out, "\n", { plain = true })) end
      lines[#lines + 1] = ""
      lines[#lines + 1] = res.code == 0 and "[ok] exit 0" or ("[error] exit " .. tostring(res.code))
      set_lines(buf, lines)
    end)
  end)

  if not ok then set_lines(buf, { title, "", "Не удалось запустить go: " .. tostring(err) }) end
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_test = {
        {
          event = "FileType",
          pattern = "go",
          callback = function()
            -- vim.keymap.set("n", "]]", go_test, { buffer = true, desc = "Go test (./...)" })
            vim.keymap.set("n", "3", go_test, { buffer = true, desc = "Go test (./...)" })
          end,
        },
      },
    },
  },
}
