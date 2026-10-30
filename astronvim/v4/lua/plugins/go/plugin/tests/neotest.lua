-- Neotest с адаптером для Go.
-- space+t+t — ближайший тест
-- space+t+g — текущий файл
-- space+t+w — отключено: тесты запускаются на space+9

-- Собирает id всех папок/файлов и просит summary их раскрыть.
-- neotest.summary.render() принимает таблицу id позиций, которые нужно
-- раскрыть, и запоминает их внутри summary.
-- Возвращает true, если появились новые (ещё не раскрытые) позиции.
local function expand_summary_all(seen)
  local neotest = require "neotest"

  local expanded, changed = {}, false
  for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
    local tree = neotest.state.positions(adapter_id)
    if tree then
      for _, node in tree:iter_nodes() do
        if #node:children() > 0 then
          local id = node:data().id
          expanded[id] = true
          if not seen[id] then
            seen[id] = true
            changed = true
          end
        end
      end
    end
  end

  -- Перерисовываем окно только когда появились новые позиции
  if changed then
    neotest.summary.render(expanded)
  end
  return changed
end

-- id адаптеров, для которых neotest уже построил дерево с тестами
local function ready_adapters()
  local ok, adapters = pcall(function()
    local neotest = require "neotest"
    local ready = {}
    for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
      local tree = neotest.state.positions(adapter_id)
      if tree and #tree:children() > 0 then
        ready[#ready + 1] = adapter_id
      end
    end
    return ready
  end)
  return ok and adapters or {}
end

-- neotest обнаруживает тесты асинхронно. Если запустить их сразу после
-- открытия файла, позиции ещё не известны, run() ничего не находит и
-- показывает лишнее окошко-уведомление "No tests found". Поэтому ждём,
-- пока is_ready() не вернёт true (но не дольше ~3 секунд).
local function run_when_ready(is_ready, run)
  local attempts = 0
  local function tick()
    attempts = attempts + 1
    local ok, ready = pcall(is_ready)
    if (ok and ready) or attempts >= 30 then
      run()
      return
    end
    vim.defer_fn(tick, 100)
  end
  vim.defer_fn(tick, 50)
end

-- Позиции текущего файла уже обнаружены (и в них есть тесты)?
local function buffer_ready()
  local neotest = require "neotest"
  local bufnr = vim.api.nvim_get_current_buf()
  for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
    local tree = neotest.state.positions(adapter_id, { buffer = bufnr })
    if tree then
      for _, node in tree:iter_nodes() do
        if node:data().type == "test" then
          return true
        end
      end
    end
  end
  return false
end

-- Открывает summary, раскрывает все папки и запускает весь набор тестов.
-- Запускаем только после того, как neotest обнаружил тесты: если вызвать
-- run.run() сразу, он не находит позиции и показывает лишнее окошко
-- "No tests found".
local function run_all_expanded()
  local neotest = require "neotest"
  neotest.summary.open()

  local seen, started, stable, attempts = {}, false, 0, 0
  local function tick()
    attempts = attempts + 1

    local adapters = ready_adapters()
    local changed = #adapters > 0 and expand_summary_all(seen)
    stable = changed and 0 or (stable + 1)

    if not started and #adapters > 0 then
      started = true
      pcall(neotest.run.run, { suite = true, adapter = adapters[1] })
    end

    -- Продолжаем, пока идёт обнаружение новых тестов (максимум ~60 с)
    if (not started or stable < 30) and attempts < 600 then
      vim.defer_fn(tick, 100)
    end
  end
  vim.defer_fn(tick, 50)
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "fredrikaverpil/neotest-golang",
    },
    keys = {
      {
        "<Leader>tt",
        function()
          require("neotest").summary.open()
          run_when_ready(buffer_ready, function()
            require("neotest").run.run()
          end)
        end,
        desc = "Run nearest Go test",
      },
      {
        "<Leader>tg",
        function()
          require("neotest").summary.open()
          run_when_ready(buffer_ready, function()
            require("neotest").run.run(vim.fn.expand "%")
          end)
        end,
        desc = "Run current Go test file",
      },
      -- space+t+w отключено: тесты запускаются на space+9
      -- (см. plugins/go/actions/go_test.lua).
      -- {
      --   "<Leader>tw",
      --   function()
      --     run_all_expanded()
      --   end,
      --   desc = "Run all Go tests",
      -- },
    },
    config = function()
      local function float_open()
        local width = math.floor(vim.o.columns * 0.92)
        local height = math.floor(vim.o.lines * 0.88)
        local buf = vim.api.nvim_create_buf(false, true)
        return vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = math.floor((vim.o.lines - height) / 2),
          col = math.floor((vim.o.columns - width) / 2),
          style = "minimal",
          border = "rounded",
        })
      end

      require("neotest").setup {
        adapters = {
          require "neotest-golang"(),
        },
        status = {
          signs = true,
          virtual_text = true,
        },
        summary = {
          open = float_open,
        },
        output_panel = {
          open = float_open,
        },
      }
    end,
  },
}
