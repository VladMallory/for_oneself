-- Клавиша 4 в go-файлах: запускает `go test -coverprofile ./...`
-- и показывает компактный отчёт о покрытии.
-- По умолчанию скрыты пакеты с 0% и функции со 100% покрытием.
-- `a` — полный отчёт, `o` — HTML для файла под курсором, `q`/Esc — закрыть.
local ns = vim.api.nvim_create_namespace "go_test_cover"
local views = {}

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
  vim.keymap.set("n", "q", "<Cmd>tabclose<CR>", { buffer = buf, desc = "Close Go coverage output" })
  vim.keymap.set("n", "<Esc>", "<Cmd>tabclose<CR>", { buffer = buf, desc = "Close Go coverage output" })
  return buf
end

local function set_lines(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

-- Подсвечиваем ключевые строки отчёта.
local function highlight(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for i, line in ipairs(lines) do
    local row = i - 1
    local group
    local pct = line:match "^%s*(%d+%.%d)%%%s"
    if pct then
      local value = tonumber(pct)
      if value == 0 then
        group = "ErrorMsg"
      elseif value < 60 then
        group = "WarningMsg"
      else
        group = "MoreMsg"
      end
    elseif line:match "^%$ " or line:match "^coverage:" or line:match "^total:" then
      group = "Title"
    elseif line:match "FAIL" then
      group = "ErrorMsg"
    elseif line:match "^ok%s" then
      group = "MoreMsg"
    elseif line:match "%.go$" then
      group = "Directory"
    elseif line:match "^%-%-%-" then
      group = "Comment"
    end
    if group then vim.api.nvim_buf_add_highlight(buf, ns, group, row, 0, -1) end
  end
end

-- Путь модуля из go.mod — чтобы убрать длинный префикс из путей.
local function module_path(root)
  local fd = io.open(root .. "/go.mod", "r")
  if not fd then return nil end
  local first = fd:read "l"
  fd:close()
  return first and first:match "^module%s+(%S+)" or nil
end

local function strip_module(text, mod)
  if not mod or mod == "" then return text end
  return (text:gsub(vim.pesc(mod) .. "/", ""))
end

-- Ищет якорь `#fileN` нужного файла в сгенерированном `go tool cover -html`.
-- Если файл не найден, возвращает первый — как открывает сам Go.
local function html_anchor(html, wanted)
  local content = table.concat(vim.fn.readfile(html), "\n")
  for anchor, name in content:gmatch '<option value="(file%d+)">([^<]*)</option>' do
    local path = name:gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">")
    path = path:match "^(.-)%s+%([%d%.]+%%%)$" or path
    if path == wanted then return anchor end
  end
  return "file0"
end

-- Разбирает вывод `go tool cover -func`: список функций и итоговый процент.
local function parse_cover(out)
  local funcs, total = {}, nil
  for line in (out or ""):gmatch "[^\r\n]+" do
    local file, name, pct = line:match "^(.-):%d+:%s+(.-)%s+([%d%.]+)%%$"
    if file then
      funcs[#funcs + 1] = { file = file, name = name, pct = tonumber(pct) or 0 }
    else
      total = line:match "^total:%s+%(statements%)%s+([%d%.]+)%%" or total
    end
  end
  return funcs, total
end

-- Функции по файлам. only_below — скрыть полностью покрытые (100%).
local function format_funcs(funcs, mod, only_below)
  local lines, shown, hidden = {}, 0, 0
  local last_file
  for _, f in ipairs(funcs) do
    if only_below and f.pct >= 99.95 then
      hidden = hidden + 1
    else
      local file = strip_module(f.file, mod)
      if file ~= last_file then
        if last_file then lines[#lines + 1] = "" end
        lines[#lines + 1] = file
        last_file = file
      end
      lines[#lines + 1] = string.format("%5.1f%%  %s", f.pct, f.name)
      shown = shown + 1
    end
  end
  return lines, shown, hidden
end

-- Компактный вывод тестов: пакеты с 0% и без тестов заменяем счётчиком.
local function compact_tests(out, mod)
  local lines, shown, hidden = {}, 0, 0
  for line in (out or ""):gmatch "[^\r\n]+" do
    local text = line:gsub("%s+$", "")
    if text ~= "" then
      local pct = text:match "coverage: ([%d%.]+)%%"
      if (pct and tonumber(pct) == 0) or text:match "^%?%s" then
        hidden = hidden + 1
      else
        if text:match "^ok%s" then shown = shown + 1 end
        lines[#lines + 1] = strip_module(text:gsub("%s+", " "), mod)
      end
    end
  end
  return lines, shown, hidden
end

local function append_block(lines, text)
  text = (text or ""):gsub("^%s*\n", ""):gsub("\n%s*$", "")
  if text ~= "" then vim.list_extend(lines, vim.split(text, "\n", { plain = true })) end
end

-- Собирает два варианта отчёта: компактный и полный (для клавиши `a`).
local function build_views(title, root, test_out, cover_out, success)
  local mod = module_path(root)
  local funcs, total = parse_cover(cover_out)

  local header = { title, "" }
  if total then header[#header + 1] = "coverage: " .. total .. "% of statements" end

  local compact, full = vim.deepcopy(header), vim.deepcopy(header)

  -- Полный вывод тестов (все строки, но без длинного префикса модуля).
  local function raw_test_lines()
    local lines = {}
    local raw = (test_out or ""):gsub("^%s*\n", ""):gsub("\n%s*$", "")
    for line in raw:gmatch "[^\r\n]+" do
      lines[#lines + 1] = strip_module(line, mod)
    end
    return lines
  end

  if success then
    local test_lines, shown, hidden = compact_tests(test_out, mod)
    compact[#compact + 1] = string.format("%d packages with tests, %d without coverage (hidden)", shown, hidden)
    if #test_lines > 0 then
      compact[#compact + 1] = ""
      vim.list_extend(compact, test_lines)
    end
  else
    local test_lines = raw_test_lines()
    if #test_lines > 0 then
      compact[#compact + 1] = ""
      vim.list_extend(compact, test_lines)
    end
  end

  local full_tests = raw_test_lines()
  if #full_tests > 0 then
    full[#full + 1] = ""
    vim.list_extend(full, full_tests)
  end

  if #funcs > 0 then
    local below, shown, hidden = format_funcs(funcs, mod, true)
    local all = format_funcs(funcs, mod, false)

    compact[#compact + 1] = ""
    compact[#compact + 1] = string.format(
      "--- functions below 100%% (%d of %d, %d fully covered hidden) ---",
      shown,
      #funcs,
      hidden
    )
    vim.list_extend(compact, below)
    if shown == 0 then compact[#compact + 1] = "all functions are fully covered" end

    full[#full + 1] = ""
    full[#full + 1] = "--- all functions ---"
    vim.list_extend(full, all)
  elseif cover_out and cover_out ~= "" then
    compact[#compact + 1] = ""
    compact[#compact + 1] = cover_out
  end

  local footer = "a: full report  o: HTML (file under cursor)  q: close"
  compact[#compact + 1] = ""
  compact[#compact + 1] = footer
  full[#full + 1] = ""
  full[#full + 1] = footer
  return compact, full
end

local function go_test_cover()
  -- Тесты компилируют файлы с диска, поэтому сохраняем буфер.
  vim.cmd "silent write"

  -- Корень модуля: папка с go.mod, иначе текущая директория.
  local root = vim.fs.root(0, "go.mod") or vim.fn.getcwd()
  local profile = vim.fn.tempname() .. ".out"
  local html = vim.fn.tempname() .. ".html"
  local cmd = { "go", "test", "-coverprofile=" .. profile, "./..." }
  local title = "$ " .. table.concat(cmd, " ")

  local buf = open_output()
  set_lines(buf, { title, "", "Running..." })

  -- Профиль, HTML и сохранённые варианты отчёта нужны только пока открыта вкладка.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      views[buf] = nil
      vim.fn.delete(profile)
      vim.fn.delete(html)
    end,
  })

  -- `o` — HTML-отчёт сразу на файле под курсором (или ближайшем заголовке выше).
  vim.keymap.set("n", "o", function()
    if vim.fn.filereadable(profile) == 0 then
      vim.notify("Профиль покрытия уже удалён", vim.log.levels.WARN)
      return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local target
    for i = row, 1, -1 do
      target = lines[i] and lines[i]:match "^([^%s]+%.go)$"
      if target then break end
    end

    -- HTML генерируем один раз на вкладку.
    if vim.fn.filereadable(html) == 0 then
      local res = vim.system({ "go", "tool", "cover", "-html=" .. profile, "-o", html }, { cwd = root, text = true }):wait()
      if res.code ~= 0 then
        local err = (res.stderr or "") .. (res.stdout or "")
        vim.notify("Не удалось создать HTML-отчёт: " .. err, vim.log.levels.ERROR)
        return
      end
    end

    -- В профиле пути с префиксом модуля, а в отчёте он обрезан.
    local mod = module_path(root)
    local wanted = target and (mod and (mod .. "/" .. target) or target)
    local anchor = wanted and html_anchor(html, wanted) or "file0"
    vim.ui.open("file://" .. html .. "#" .. anchor)
  end, { buffer = buf, desc = "Open coverage HTML for file under cursor" })

  -- `a` — переключить компактный/полный отчёт.
  vim.keymap.set("n", "a", function()
    local view = views[buf]
    if not view then return end
    view.mode = view.mode == "full" and "compact" or "full"
    local lines = view[view.mode]
    set_lines(buf, lines)
    highlight(buf, lines)
  end, { buffer = buf, desc = "Toggle full Go coverage report" })

  local ok, err = pcall(vim.system, cmd, { cwd = root, text = true }, function(res)
    local test_out = (res.stdout or "") .. (res.stderr or "")
    vim.schedule(function()
      local function render(cover_out)
        local compact, full = build_views(title, root, test_out, cover_out, res.code == 0)
        if res.code ~= 0 then
          for _, lines in ipairs { compact, full } do
            lines[#lines + 1] = ""
            lines[#lines + 1] = "exit=" .. tostring(res.code)
          end
        end
        views[buf] = { compact = compact, full = full, mode = "compact" }
        set_lines(buf, compact)
        highlight(buf, compact)
      end

      if vim.fn.filereadable(profile) == 0 then
        render "Нет данных о покрытии: профиль не создан (возможно, в модуле нет тестов)."
        return
      end

      -- Профиль может быть создан даже при падении тестов — отчёт всё равно строим.
      vim.system({ "go", "tool", "cover", "-func=" .. profile }, { cwd = root, text = true }, function(cov)
        vim.schedule(function()
          local cover_out = (cov.stdout or "") .. (cov.stderr or "")
          if cov.code ~= 0 and cover_out == "" then cover_out = "Не удалось построить отчёт о покрытии." end
          render(cover_out)
        end)
      end)
    end)
  end)

  if not ok then
    set_lines(buf, { title, "", "Не удалось запустить go: " .. tostring(err) })
  end
end

return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_test_cover = {
        {
          event = "FileType",
          pattern = "go",
          callback = function()
            vim.keymap.set("n", "4", go_test_cover, { buffer = true, desc = "Go test with coverage (./...)" })
          end,
        },
      },
    },
  },
}
