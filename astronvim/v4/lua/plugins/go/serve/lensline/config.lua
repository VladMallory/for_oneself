-- Показывает "2 references | 1 implementation" над каждой функцией.
-- Стиль как в JetBrains IDE.
return {
  {
    "oribarilan/lensline.nvim",
    tag = "v2.1.0",
    event = "LspAttach",
    config = function()
      require("lensline").setup {
        profiles = {
          {
            name = "jetbrains",
            providers = {
              {
                name = "usages",
                enabled = true,
                include = { "impls", "refs" },
                breakdown = true,
                show_zero = true,
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
    end,
  },
}
