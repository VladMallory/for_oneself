-- Отключаем LSP-форматтер gopls для Go на сохранении.
-- Без этого gopls запускает gofmt после нашего golangci-lint fmt
-- и ломает форматирование (gofumpt > gofmt).
-- Форматированием занимается go/serve/formatter/golangci.lua.
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      format_on_save = {
        ignore_filetypes = { "go" },
      },
    },
  },
}
