-- Модуль сохранения состояния AI-плагинов
local M = {}
local state_file = vim.fn.stdpath("config") .. "/lua/plugins/plugins/ai/state.json"

function M.load()
  local f = io.open(state_file)
  if not f then return { supermaven = false, minuet = false } end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if ok then return data end
  return { supermaven = false, minuet = false }
end

function M.save(state)
  local f = io.open(state_file, "w")
  if f then
    f:write(vim.json.encode(state))
    f:close()
  end
end

function M.toggle(plugin)
  local s = M.load()
  s[plugin] = not s[plugin]
  M.save(s)
  if plugin == "supermaven" then
    vim.cmd(s.supermaven and "SupermavenStart" or "SupermavenStop")
  elseif plugin == "minuet" then
    vim.cmd(s.minuet and "Minuet virtualtext enable" or "Minuet virtualtext disable")
  end
end

function M.disable_all()
  M.save({ supermaven = false, minuet = false })
  vim.cmd("SupermavenStop")
  vim.cmd("Minuet virtualtext disable")
end

return M
