-- gotests: генерация табличных тестов для Go.
-- <Leader>ty — тест для функции под курсором
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>ty"] = {
          function()
            local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
            local params = vim.lsp.util.make_position_params()
            local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
            if not responses then
              vim.notify("LSP: no response", vim.log.levels.WARN)
              return
            end

            local fn_name
            local function find_in(symbols, depth)
              if depth > 4 then return end
              for _, sym in ipairs(symbols) do
                if sym.kind == 12 then
                  local range = sym.range or (sym.location and sym.location.range)
                  if range and range.start.line <= row and row <= range["end"].line then
                    fn_name = sym.name
                    break
                  end
                end
                if not fn_name and sym.children then
                  find_in(sym.children, depth + 1)
                end
              end
            end

            for _, res in pairs(responses) do
              if res.result then
                find_in(res.result, 0)
                if fn_name then break end
              end
            end

            if not fn_name then
              vim.notify("No function found at cursor", vim.log.levels.WARN)
              return
            end
            vim.cmd('!gotests -only "' .. fn_name .. '" ' .. vim.fn.expand "%")
          end,
          desc = "Go test for current function",
        },
      },
    },
  },
}
