-- Отключаем lens references у rust-analyzer, чтобы не мерцало при печати.
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    config = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            lens = {
              references = false,
            },
          },
        },
      },
    },
  },
}
