-- Aerial: боковая панель с оглавлением файла (функции, методы, структуры).
-- space+2 — открыть/закрыть.
-- Показывает дерево символов: удобно прыгать по функциям в большом файле.
return {
  "stevearc/aerial.nvim",
  keys = {
    { "<Leader>2", "<Cmd>AerialToggle<CR>", desc = "Toggle Aerial outline" },
  },
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    post_parse_symbol = function(_bufnr, item, ctx)
      local detail = ctx.symbol and ctx.symbol.detail
      if detail and detail ~= "" then item.name = item.name .. " " .. detail end
      return true
    end,
  },
}
