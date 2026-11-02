-- Показывает "2 references | 1 implementation" над функциями, методами,
-- структурами и интерфейсами. Стиль как в JetBrains IDE.
--
-- Альтернативный вариант: скрыть строки, когда refs и impls равны 0.
-- Для этого замени show_zero = true на show_zero = false (строка ниже).
-- Тогда надпись будет появляться только при наличии ссылок/реализаций,
-- и спам "0 implementations | 0 references" не будет отображаться.
    -- show_zero = false,
return {
  {
    "oribarilan/lensline.nvim",
    tag = "v2.1.0",
    event = "LspAttach",
    config = function()
      require("lensline").setup {
        -- Большой debounce, чтобы на сохранении (BufWritePre формат + gopls
        -- переиндексация) не было промежуточного пустого состояния линз.
        -- Старые линзы остаются висеть, пока не придут новые данные.
        debounce_ms = 10,
        silence_lsp = true,
        profiles = {
          {
            name = "jetbrains",
            providers = {
              {
                name = "usages",
                enabled = true,
                include = { "impls", "refs" },
                breakdown = true,
                show_zero = false,
                labels = {
                  impls = "implementations",
                  refs = "references",
                },
                icon_for_single = "",
                inner_separator = " | ",
              },
            },
            style = {
              prefix = "| ",
              separator = " | ",
              placement = "above",
              highlight = "Comment",
              use_nerdfont = false,
              render = "all",
            },
          },
        },
      }

      -- NOTE: здесь раньше был monkey-patch с renderer.clear_buffer()
      -- перед каждым render_combined_lenses ("фикс накопления").
      -- Он и давал мигание: линзы стирались и рисовались заново на каждое
      -- сохранение, код прыгал туда-сюда. В lensline v2.1.0 рендерер сам
      -- делает diff (обновляет только изменённые строки и удаляет устаревшие),
      -- поэтому принудительный clear не нужен и вреден. Удалено.

      -- Фикс для gopls: исправляет позицию имени функции в ответах LSP
      local utils = require "lensline.utils"
      local orig_refs = utils.get_lsp_references
      local orig_impls = utils.get_lsp_implementations

      local function escape_lua_pattern(s) return s:gsub("([%.%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1") end

      local function fix_func_info(func_info, bufnr)
        local fixed = vim.deepcopy(func_info)
        if fixed.name then
          local simple_name = fixed.name:match "[^.]*$"
          if simple_name then
            local line = vim.api.nvim_buf_get_lines(bufnr, fixed.line - 1, fixed.line, false)[1] or ""
            local pattern = escape_lua_pattern(simple_name) .. "%("
            local name_start = line:find(pattern)
            if name_start then fixed.character = name_start end
          end
        end
        return fixed
      end

      utils.get_lsp_references = function(bufnr, func_info, callback)
        orig_refs(bufnr, fix_func_info(func_info, bufnr), callback)
      end

      utils.get_lsp_implementations = function(bufnr, func_info, callback)
        orig_impls(bufnr, fix_func_info(func_info, bufnr), callback)
      end

      -- Lensline по умолчанию показывает линзы только над Function/Method/
      -- Constructor (см. lens_explorer.extract_symbols_recursive). Добавляем
      -- Struct/Interface, чтобы usage-линза появлялась и над типами Go.
      --
      -- Обёртка нужна, потому что оригинальная функция рекурсивно вызывает
      -- саму себя через M.extract_symbols_recursive: на верхнем уровне даём
      -- ей собрать функции, а затем один раз обходим дерево и добавляем типы.
      local explorer = require "lensline.lens_explorer"
      local orig_extract = explorer.extract_symbols_recursive
      local extra_kinds = {
        [vim.lsp.protocol.SymbolKind.Struct] = true,
        [vim.lsp.protocol.SymbolKind.Interface] = true,
      }

      local function collect_extra_symbols(symbols, out, start_line, end_line)
        for _, symbol in ipairs(symbols) do
          if extra_kinds[symbol.kind] then
            local range = symbol.range or (symbol.location and symbol.location.range)
            if range then
              local line = range.start.line + 1
              local symbol_end_line = range["end"].line + 1
              if line >= start_line and line <= end_line then
                table.insert(out, {
                  line = line,
                  end_line = symbol_end_line,
                  character = range.start.character,
                  name = symbol.name,
                  kind = symbol.kind,
                })
              end
            end
          end
          if symbol.children then
            collect_extra_symbols(symbol.children, out, start_line, end_line)
          end
        end
      end

      local extract_depth = 0
      explorer.extract_symbols_recursive = function(symbols, functions, start_line, end_line)
        -- Рекурсивные вызовы оригинальной функции не должны добавлять типы
        -- повторно на каждом уровне вложенности.
        if extract_depth > 0 then
          return orig_extract(symbols, functions, start_line, end_line)
        end

        extract_depth = 1
        local ok, err = pcall(orig_extract, symbols, functions, start_line, end_line)
        extract_depth = 0
        if not ok then error(err) end

        collect_extra_symbols(symbols, functions, start_line, end_line)
        table.sort(functions, function(a, b) return (a.line or 0) < (b.line or 0) end)
      end
    end,
  },
}
