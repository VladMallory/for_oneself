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
    layout = {
      -- Ширина окна outline. Можно целое число (колонки) или долю от экрана (0-1).
      -- max_width = { 60, 0.35 } означает "меньшее из 60 колонок или 35% экрана".
      max_width = { 85, 0.45 },
      min_width = 45,
      width = 65,
      resize_to_content = true,
    },
    post_parse_symbol = function(_bufnr, item, ctx)
      local detail = ctx.symbol and ctx.symbol.detail
      if detail and detail ~= "" then item.name = item.name .. " " .. detail end
      return true
    end,
  },
}
