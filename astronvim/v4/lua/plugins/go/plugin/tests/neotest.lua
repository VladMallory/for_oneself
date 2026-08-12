-- Neotest с адаптером для Go.
-- space+t+t — ближайший тест
-- space+t+g — текущий файл
-- space+t+w — весь проект
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
          require("neotest").run.run()
        end,
        desc = "Run nearest Go test",
      },
      {
        "<Leader>tg",
        function()
          require("neotest").summary.open()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Run current Go test file",
      },
      {
        "<Leader>tw",
        function()
          local root = vim.fs.root(0, { "go.work", "go.mod", ".git" }) or vim.fn.getcwd()
          require("neotest").summary.open()
          require("neotest").run.run(root)
        end,
        desc = "Run all Go tests",
      },
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
