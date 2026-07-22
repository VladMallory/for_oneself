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
      require("neotest").setup {
        adapters = {
          require "neotest-golang"(),
        },
        status = {
          signs = true,
          virtual_text = true,
        },
      }
    end,
  },
}
