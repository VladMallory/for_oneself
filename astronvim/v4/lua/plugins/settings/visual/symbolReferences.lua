-- Подсветка всех вхождений символа, на котором стоит курсор.
--
-- Когда курсор замирает на слове (CursorHold), подсвечиваются все его
-- использования в текущем буфере: и объявление, и чтения, и записи.
-- Для языков с LSP (Go, Rust и т.д.) используется textDocument/documentHighlight,
-- поэтому учитываются реальные связи символа, а не просто совпадение текста.
-- Для файлов без LSP работает запасной поиск по границам слова.
--
-- Цвета: чтения — холодный фон, записи (объявление) — тёплый.
-- Само слово под курсором не трогаем — оно остаётся как было, а всё
-- остальное вокруг становится заметным. Подсветка снимается при движении курсора.
return {
  "AstroNvim/astrocore",
  init = function()
    local ns = vim.api.nvim_create_namespace "user_symbol_references"
    local generation = 0
    -- Слишком короткие слова (например, одна буква) дают много шума.
    local min_word_length = 2

    -- 1 = Text, 2 = Read, 3 = Write (LSP DocumentHighlightKind)
    local kind_hl = {
      [1] = "LspReferenceText",
      [2] = "LspReferenceRead",
      [3] = "LspReferenceWrite",
    }

    local function apply_colors()
      vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#458588", fg = "#f0fdfd", bold = true })
      vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#458588", fg = "#f0fdfd", bold = true })
      vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#458588", fg = "#f0fdfd", bold = true })
    end

    apply_colors()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_colors })

    -- Слово под курсором и его границы (в байтах, 0-based).
    -- \k учитывает iskeyword, поэтому не подсвечиваем пробелы и пунктуацию.
    local function word_at_cursor()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_get_current_line()
      local col = cursor[2]

      local left = vim.fn.matchstr(line:sub(1, col + 1), "\\k*$")
      if left == "" then return nil end
      local right = vim.fn.matchstr(line:sub(col + 2), "^\\k*")

      local word = left .. right
      if #word < min_word_length then return nil end

      local start_col = col + 1 - #left
      return word, start_col, start_col + #word
    end

    local to_byte = vim.lsp.util.get_line_byte_from_position or vim.lsp.util._get_line_byte_from_position

    local function clear_marks(bufnr)
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
      end
    end

    local function cancel(bufnr)
      generation = generation + 1
      clear_marks(bufnr)
    end

    -- Слово под курсором пропускаем: оно должно остаться без подсветки.
    -- Сравниваем с пересечением, а не с точным совпадением границ:
    -- LSP иногда отдаёт диапазон чуть иначе, чем мы посчитали.
    local function is_cursor_word(row, start_col, end_col, cursor_row, cursor_start, cursor_end)
      return row == cursor_row and start_col < cursor_end and end_col > cursor_start
    end

    local function draw_range(bufnr, range, hl, encoding, cursor_row, cursor_start, cursor_end)
      local ok_start, start_col = pcall(to_byte, bufnr, range.start, encoding)
      local ok_end, end_col = pcall(to_byte, bufnr, range["end"], encoding)
      if not ok_start or not ok_end then return end
      if is_cursor_word(range.start.line, start_col, end_col, cursor_row, cursor_start, cursor_end) then return end

      vim.api.nvim_buf_set_extmark(bufnr, ns, range.start.line, start_col, {
        end_row = range["end"].line,
        end_col = end_col,
        hl_group = hl,
        priority = vim.hl.priorities.user,
      })
    end

    local function has_lsp_highlight(bufnr)
      for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
        if client:supports_method("textDocument/documentHighlight", bufnr) then return true end
      end
      return false
    end

    -- Точные связи символа через LSP.
    local function lsp_references(bufnr, row, start_col, end_col, gen)
      vim.lsp.buf_request_all(bufnr, "textDocument/documentHighlight", function(client)
        return vim.lsp.util.make_position_params(0, client.offset_encoding)
      end, function(results)
        -- Пока сервер отвечал, курсор мог уехать или буфер — закрыться.
        if gen ~= generation or not vim.api.nvim_buf_is_valid(bufnr) then return end
        if vim.api.nvim_get_current_buf() ~= bufnr then return end

        clear_marks(bufnr)

        for _, response in pairs(results) do
          local references = response.result
          if references and #references > 0 then
            local client = response.context and vim.lsp.get_client_by_id(response.context.client_id)
            local encoding = client and client.offset_encoding or "utf-16"
            for _, reference in ipairs(references) do
              local hl = kind_hl[reference.kind] or "LspReferenceText"
              draw_range(bufnr, reference.range, hl, encoding, row, start_col, end_col)
            end
          end
        end
      end)
    end

    -- Запасной вариант: все текстовые совпадения целым словом.
    local function text_references(bufnr, word, row, start_col, end_col)
      local pattern = "%f[%w_]" .. vim.pesc(word) .. "%f[%W_]"

      for index, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        local init = 1
        while true do
          local first, last = line:find(pattern, init)
          if not first then break end
          if not is_cursor_word(index - 1, first - 1, last, row, start_col, end_col) then
            vim.api.nvim_buf_set_extmark(bufnr, ns, index - 1, first - 1, {
              end_col = last,
              hl_group = "LspReferenceText",
              priority = vim.hl.priorities.user,
            })
          end
          init = last + 1
        end
      end
    end

    local function highlight(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      if vim.api.nvim_get_current_buf() ~= bufnr then return end
      if vim.bo[bufnr].buftype ~= "" then return end

      generation = generation + 1
      local gen = generation
      clear_marks(bufnr)

      local word, start_col, end_col = word_at_cursor()
      if not word then return end

      local row = vim.api.nvim_win_get_cursor(0)[1] - 1
      if has_lsp_highlight(bufnr) then
        lsp_references(bufnr, row, start_col, end_col, gen)
      else
        text_references(bufnr, word, row, start_col, end_col)
      end
    end

    local group = vim.api.nvim_create_augroup("UserSymbolReferences", { clear = true })

    vim.api.nvim_create_autocmd("CursorHold", {
      group = group,
      desc = "Подсветить все вхождения символа под курсором",
      callback = function(args) highlight(args.buf) end,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
      group = group,
      desc = "Снять подсветку вхождений символа",
      callback = function(args) cancel(args.buf) end,
    })
  end,
}
