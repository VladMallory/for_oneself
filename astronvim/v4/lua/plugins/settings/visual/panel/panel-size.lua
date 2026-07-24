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
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = {
          {
            function()
              local fname = vim.api.nvim_buf_get_name(0)
              if fname == "" then return "" end
              local stat = vim.loop.fs_stat(fname)
              if not stat then return "" end
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
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
