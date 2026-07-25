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
        },
        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn", "info", "hint" },
            symbols = {
              error = "🚨",
              warn = "💡",
              info = "🔍",
              hint = "📝",
            },
            colored = true,
            update_in_insert = false,
            always_visible = false,
          },
        },

        lualine_x = { "filename" },

        lualine_y = {
          {
            function()
              local fname = vim.api.nvim_buf_get_name(0)
              if fname == "" then
                return ""
              end
              local stat = vim.loop.fs_stat(fname)
              if not stat then
                return ""
              end
              local size = stat.size
              local units = { "B", "KB", "MB", "GB" }
              local idx = 1
              while size >= 1024 and idx < #units do
                size = size / 1024
                idx = idx + 1
              end
              if idx == 1 then
                return string.format("%d %s", size, units[idx])
              else
                return string.format("%.1f %s", size, units[idx])
              end
            end,
          },
          "fileformat",
          "filetype",
        },
        lualine_z = {
          "progress",
          "location",
        },
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
