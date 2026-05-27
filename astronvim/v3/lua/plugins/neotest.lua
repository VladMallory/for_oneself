local function project_root()
  return vim.fs.root(0, { "go.work", "go.mod", ".git" }) or vim.fn.getcwd()
end

local function run_nearest()
  vim.notify "Running nearest Go test"
  require("neotest").summary.open()
  require("neotest").run.run()
end

local function run_file()
  vim.notify "Running current Go test file"
  require("neotest").summary.open()
  require("neotest").run.run(vim.fn.expand "%")
end

local function run_project()
  vim.notify "Running all Go tests"
  require("neotest").summary.open()
  require("neotest").run.run(project_root())
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
    },
    keys = {
      {
        "<Leader>tt",
        run_nearest,
        desc = "Run nearest Go test",
      },
      {
        "<Leader>tg",
        run_file,
        desc = "Run current Go test file",
      },
      {
        "<Leader>tw",
        run_project,
        desc = "Run all Go tests",
      },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require("neotest-golang")(),
        },
        status = {
          signs = true,
          virtual_text = true,
        },
      }
    end,
  },
}
