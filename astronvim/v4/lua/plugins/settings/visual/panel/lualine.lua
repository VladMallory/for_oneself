return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "gruvbox",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        -- ============================================================
        -- ЛЕВАЯ ЧАСТЬ ПАНЕЛИ
        -- ============================================================
        lualine_a = { "mode" },

        -- diagnostics: ошибки LSP + предупреждения линтеров (кликабельно)
        lualine_b = {
          "branch",
          "diff",
          {
            function()
              local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
              local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
              local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
              local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
              local total = errors + warns + infos + hints
              if total == 0 then return "" end
              local parts = {}
              if errors > 0 then table.insert(parts, string.format("\u{1F4DB}%d", errors)) end
              if warns > 0 then table.insert(parts, string.format("\u{1F4CE}%d", warns)) end
              if infos > 0 then table.insert(parts, string.format("\u{1F4CB}%d", infos)) end
              if hints > 0 then table.insert(parts, string.format("\u{1F4A1}%d", hints)) end
              return " " .. table.concat(parts, " ")
            end,
            on_click = function()
              local diagnostics = vim.diagnostic.get(0)
              if #diagnostics == 0 then
                vim.notify("No diagnostics", vim.log.levels.INFO)
                return
              end
              local lines = {}
              for _, d in ipairs(diagnostics) do
                local severity = ({ "INFO", "HINT", "WARN", "ERROR" })[d.severity] or "? "
                table.insert(lines, string.format("[%s] %d:%d %s", severity, d.lnum + 1, d.col + 1, d.message))
              end
              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              local width = math.min(math.max(vim.fn.winwidth(0) - 10, 40), 80)
              local height = math.min(#lines + 2, 20)
              local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                col = math.floor((vim.o.columns - width) / 2),
                row = math.floor((vim.o.lines - height) / 2),
                style = "minimal",
                border = "single",
              })
              local jump = function()
                local cursor = vim.api.nvim_win_get_cursor(win)
                local line = cursor[1]
                local d = diagnostics[line]
                if d then
                  vim.api.nvim_win_close(win, true)
                  vim.api.nvim_set_current_buf(d.bufnr)
                  vim.api.nvim_win_set_cursor(0, { d.lnum + 1, d.col })
                end
              end
              vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", { noremap = true, callback = jump })
              vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { silent = true, noremap = true })
              vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { silent = true, noremap = true })
            end,
          },
        },

        -- ============================================================
        -- ЦЕНТР ПАНЕЛИ
        -- ============================================================
        lualine_c = { "filename" },

        -- ============================================================
        -- ПРАВАЯ ЧАСТЬ ПАНЕЛИ
        -- ============================================================
        lualine_x = { "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.defer_fn(function()
        vim.o.statusline = "%{%v:lua.require'lualine'.statusline()%}"
      end, 100)
    end,
  },
}
