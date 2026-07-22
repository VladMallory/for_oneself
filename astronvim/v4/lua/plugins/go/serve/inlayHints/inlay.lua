-- Inlay hints: gopls показывает имена параметров прямо в коде.
-- doSomething(true, 42) → doSomething(verbose: true, count: 42)
-- Также включает gofumpt, staticcheck, автоимпорты для gopls.
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      inlay_hints = true,
    },
    config = {
      gopls = {
        settings = {
          gopls = {
            hints = {
              parameterNames = true,
            },
            gofumpt = true,
            completeUnimported = true,
            staticcheck = true,
            analyses = {
              ST1000 = false, -- не требовать комментарий в начале пакета
            },
          },
        },
      },
    },
  },
}
