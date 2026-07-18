return {
  "stevearc/aerial.nvim",
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },
    post_parse_symbol = function(bufnr, item, ctx)
      local detail = ctx.symbol and ctx.symbol.detail
      if detail and detail ~= "" then
        item.name = item.name .. " " .. detail
      end
      return true
    end,
  },
}
