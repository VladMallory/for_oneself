-- Клавиша 5 в go-файлах: включает/выключает подсветку покрытия текущего файла.
-- Зелёный — строка покрыта тестами, красный — нет, жёлтый — частично.
-- Синтаксис, Treesitter и semantic tokens не трогаем: они остаются как есть,
-- а покрытие рисуется поверх фона строк. Повторное нажатие 5 убирает подсветку.
local ns = vim.api.nvim_create_namespace "go_coverage"
local state = {}

local function define_highlights()
  local dark = vim.o.background == "dark"
  vim.api.nvim_set_hl(0, "GoCoverageCovered", {
    bg = dark and "#1e3a24" or "#d8f5dc",
    ctermbg = 22,
    default = true,
  })
  vim.api.nvim_set_hl(0, "GoCoverageUncovered", {
    bg = dark and "#4a1f1f" or "#f7d6d6",
    ctermbg = 52,
    default = true,
  })
  vim.api.nvim_set_hl(0, "GoCoveragePartial", {
    bg = dark and "#4a3f1a" or "#f7f0cc",
    ctermbg = 58,
    default = true,
  })
end

-- Путь модуля из go.mod — чтобы сопоставить файл с профилем покрытия.
local function module_path(root)
  local fd = io.open(root .. "/go.mod", "r")
  if not fd then return nil end
  local first = fd:read "l"
  fd:close()
  return first and first:match "^module%s+(%S+)" or nil
end

local function rel_path(buf, root)
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then return nil end
  file = vim.fn.fnamemodify(file, ":p")
  local prefix = root .. "/"
  if file:sub(1, #prefix) == prefix then return file:sub(#prefix + 1) end
  return vim.fn.fnamemodify(file, ":.")
end

-- Строки профиля: file.go:startLine.startCol,endLine.endCol numStmt count
local function parse_profile(path)
  local blocks = {}
  local fd = io.open(path, "r")
  if not fd then return blocks end
  for line in fd:lines() do
    local file, sl, el, count = line:match "^(.+):(%d+)%.%d+,(%d+)%.%d+%s+%d+%s+(%d+)$"
    if file then
      blocks[#blocks + 1] = {
        file = file,
        start_line = tonumber(sl),
        end_line = tonumber(el),
        count = tonumber(count),
      }
    end
  end
  fd:close()
  return blocks
end

local function file_blocks(blocks, rel, mod)
  local wanted = mod and (mod .. "/" .. rel) or rel
  local out = {}
  for _, b in ipairs(blocks) do
    if b.file == wanted or b.file == rel or b.file:sub(-(#rel + 1)) == "/" .. rel then
      out[#out + 1] = b
    end
  end
  return out
end

-- Ставит построчные extmarks: зелёный/красный/жёлтый.
local function apply(buf, blocks)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if not vim.api.nvim_buf_is_valid(buf) or #blocks == 0 then return false end

  local last = vim.api.nvim_buf_line_count(buf)
  local flags = {}
  for _, b in ipairs(blocks) do
    local first = math.max(b.start_line, 1)
    local finish = math.min(b.end_line, last)
    for line = first, finish do
      local f = flags[line]
      if not f then
        f = { covered = false, uncovered = false }
        flags[line] = f
      end
      if b.count > 0 then
        f.covered = true
      else
        f.uncovered = true
      end
    end
  end

  for line, f in pairs(flags) do
    local group
    if f.covered and f.uncovered then
      group = "GoCoveragePartial"
    elseif f.covered then
      group = "GoCoverageCovered"
    else
      group = "GoCoverageUncovered"
    end
    vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, { line_hl_group = group, priority = vim.hl.priorities.user })
  end
  return true
end

local function clear(buf, notify)
  local st = state[buf]
  if not st then return end
  state[buf] = nil
  if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
  vim.fn.delete(st.profile)
  if notify then vim.notify("Go coverage: выключено", vim.log.levels.INFO) end
end

local function start(buf)
  local root = vim.fs.root(buf, "go.mod") or vim.fn.getcwd()
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fn.fnamemodify(file, ":h")
  local profile = vim.fn.tempname() .. ".out"
  local gen = (state[buf] and state[buf].gen or 0) + 1

  state[buf] = {
    active = true,
    gen = gen,
    profile = profile,
  }

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      local st = state[buf]
      state[buf] = nil
      if st then vim.fn.delete(st.profile) end
    end,
  })

  vim.notify("Go coverage: запускаю тесты…", vim.log.levels.INFO)

  vim.system({ "go", "test", "-coverprofile=" .. profile, "." }, { cwd = dir, text = true }, function(res)
    vim.schedule(function()
      local st = state[buf]
      if not st or not st.active or st.gen ~= gen then
        vim.fn.delete(profile)
        return
      end

      if vim.fn.filereadable(profile) == 0 then
        clear(buf, false)
        vim.notify("Go coverage: профиль не создан — нет тестов или ошибка сборки", vim.log.levels.WARN)
        return
      end

      local blocks = parse_profile(profile)
      local rel = rel_path(buf, root)
      local mod = module_path(root)
      local mine = rel and file_blocks(blocks, rel, mod) or {}

      if #mine == 0 then
        clear(buf, false)
        vim.notify("Go coverage: текущий файл не участвует в покрытии (например, _test.go)", vim.log.levels.WARN)
        return
      end

      apply(buf, mine)
      if res.code ~= 0 then
        vim.notify("Go coverage: тесты упали, покрытие может быть неполным", vim.log.levels.WARN)
      end
    end)
  end)
end

local function toggle()
  local buf = vim.api.nvim_get_current_buf()
  local st = state[buf]
  if st and st.active then
    clear(buf, true)
    return
  end

  if not pcall(vim.cmd, "silent write") then
    vim.notify("Go coverage: не удалось сохранить файл", vim.log.levels.ERROR)
    return
  end

  define_highlights()
  start(buf)
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_coverage_toggle = {
        {
          event = "FileType",
          pattern = "go",
          callback = function()
            vim.keymap.set("n", "5", toggle, { buffer = true, desc = "Toggle Go coverage highlight" })
          end,
        },
      },
    },
  },
}
