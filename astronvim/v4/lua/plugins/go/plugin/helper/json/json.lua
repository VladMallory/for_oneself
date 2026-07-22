-- space + 6 — добавляет JSON-теги к полям структуры.
-- gomodifytags анализирует структуру под курсором и добавляет `json:"field_name"`.
-- Требует бинарник gomodifytags: go install github.com/fatih/gomodifytags@latest
return {
  {
    "simondrake/gomodifytags",
    ft = "go",
    keys = {
      {
        "<Leader>6",
        function() require("gomodifytags").GoAddTags "json" end,
        desc = "Add JSON struct tags",
      },
    },
    init = function()
      local go_bin = vim.fn.expand "$HOME/go/bin"
      if vim.fn.executable "gomodifytags" == 0 and vim.fn.isdirectory(go_bin) == 1 then
        vim.env.PATH = go_bin .. ":" .. vim.env.PATH
      end
    end,
    opts = {
      parse = { enabled = true, separator = "--" },
    },
    config = function(_, opts) require("gomodifytags").setup(opts) end,
  },
}
