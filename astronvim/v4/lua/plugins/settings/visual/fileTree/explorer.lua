-- Раскрывает папки, где есть работа в git:
--   * если есть изменения (git status) — папки с изменёнными/новыми файлами;
--   * если изменений нет — папки с файлами из последнего коммита.
local function expand_git_dirs(state)
  if not state or not state.path then return end
  local utils = require "neo-tree.utils"
  local fs_scan = require "neo-tree.sources.filesystem.lib.fs_scan"
  local root = utils.normalize_path(state.path)

  --- Выполняет git в корне дерева. Возвращает stdout или nil при ошибке.
  local function git(args)
    local cmd = { "git", "-C", root }
    vim.list_extend(cmd, args)
    local res = vim.system(cmd, { text = false }):wait()
    if res.code ~= 0 then return nil end
    return res.stdout
  end

  local toplevel = git { "rev-parse", "--show-toplevel" }
  if not toplevel then
    vim.notify("neo-tree: это не git-репозиторий", vim.log.levels.WARN)
    return
  end
  toplevel = vim.trim(toplevel):gsub("/+$", "")

  local rel_paths = {}
  local status = git { "status", "--porcelain=v1", "-z", "--untracked-files=all" }
  if status and status ~= "" then
    -- Записи в формате "XY путь"; у rename/copy следующая запись — старый путь.
    local records = vim.split(status, "\0", { plain = true })
    local i = 1
    while i <= #records do
      local record = records[i]
      if #record >= 4 and record:sub(3, 3) == " " then
        rel_paths[#rel_paths + 1] = record:sub(4)
        if record:sub(1, 2):find "[RC]" then i = i + 1 end
      end
      i = i + 1
    end
  else
    -- Изменений нет — берём файлы последнего коммита (у merge — его первой ветки).
    local last = git {
      "log",
      "-1",
      "--pretty=format:",
      "--name-only",
      "-z",
      "--diff-merges=first-parent",
      "HEAD",
    }
    if last then
      for _, path in ipairs(vim.split(last, "\0", { plain = true })) do
        path = path:gsub("^[\r\n]+", ""):gsub("[\r\n]+$", "")
        if path ~= "" then rel_paths[#rel_paths + 1] = path end
      end
    end
  end

  -- Оставляем только пути внутри корня дерева и группируем по папкам:
  -- чтобы раскрыть папку, достаточно «показать» один файл из неё.
  local to_reveal, seen_dirs = {}, {}
  for _, rel in ipairs(rel_paths) do
    local abs = toplevel .. "/" .. rel:gsub("^/+", "")
    abs = abs:gsub("/+$", "")
    local dir = utils.split_path(abs)
    if dir and not seen_dirs[dir] and utils.is_subpath(root, abs) then
      seen_dirs[dir] = true
      to_reveal[#to_reveal + 1] = abs
    end
  end
  table.sort(to_reveal)

  -- Раскрываем по очереди: get_items раскроет всех родителей указанного пути.
  local function step()
    local path = table.remove(to_reveal, 1)
    if path then fs_scan.get_items_sync(state, nil, path, step) end
  end
  step()
end

-- Скрываем .DS_Store в neo-tree (space + e).
-- macOS создаёт эти файлы в каждой папке — мешают навигации.
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    opts.filesystem = opts.filesystem or {}
    opts.filesystem.filtered_items = opts.filesystem.filtered_items or {}
    opts.filesystem.filtered_items.never_show = { ".DS_Store" }
    -- Ширина боковой панели Neo-tree (Space + e). По умолчанию ~30, ставим побольше.
    opts.window = opts.window or {}
    opts.window.width = 40
    -- Клавиши внутри проводника (Space + e):
    --   o — раскрыть все папки, z — свернуть все папки.
    -- Замечание: было o — меню "Order by" (oc, od, ...), теперь оно перекрыто.
    opts.window.mappings = opts.window.mappings or {}
    opts.window.mappings["o"] = "expand_all_nodes"
    opts.window.mappings["z"] = "close_all_nodes"
    -- p — раскрыть папки с git-изменениями (или из последнего коммита, если изменений нет).
    -- Старое p (вставка из clipboard) перенесено на <C-p>.
    opts.filesystem.window = opts.filesystem.window or {}
    opts.filesystem.window.mappings = opts.filesystem.window.mappings or {}
    opts.filesystem.window.mappings["p"] = expand_git_dirs
    opts.filesystem.window.mappings["<C-p>"] = "paste_from_clipboard"
    return opts
  end,
}
