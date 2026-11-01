-- Semantic tokens — цветная подсветка идентификаторов от LSP.
-- По умолчанию выключены: gopls не перекрашивает переменные, параметры
-- и функции поверх Treesitter.
--
-- Включить обратно: поменять false на true. При false AstroLSP также
-- убирает semanticTokensProvider из возможностей клиента и блокирует
-- тумблер <Leader>uY с сообщением "disabled globally".
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      semantic_tokens = false,
    },
  },
}
