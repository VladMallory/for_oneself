
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
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          "diff",
          {
            "diagnostics",
            on_click = function()
              local diagnostics = vim.diagnostic.get(0)
              if #diagnostics == 0 then
                vim.notify("No diagnostics", vim.log.levels.INFO)
                return
              end
              local lines = {}
              for _, d in ipairs(diagnostics) do
                local severity = ({ "INFO", "HINT", "WARN", "ERROR" })[d.severity] or "? "
                local row = d.lnum
                local col = d.col
                table.insert(lines, string.format("[%s] %d:%d %s", severity, row + 1, col + 1, d.message))
              end
              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              vim.api.nvim_set_option_value("filetype", "lualine_diagnostics", { buf = buf })
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
              vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { silent = true, noremap = true })
              vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { silent = true, noremap = true })
            end,
            sources = { "nvim_lsp", "nvim_diagnostic" },
          },
        },
        lualine_c = { "filename" },
        lualine_x = { "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
