-- Список Mason-пакетов для автоустановки.
-- list_insert_unique добавляет к дефолтному списку, не затирая его.
-- Имена пакетов смотри через :Mason.
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, {
        -- golang
        "gopls",
        "gofumpt",
        "golangci-lint",

        "gomodifytags",
        "iferr",

        -- rust
        "rust-analyzer",
      })
    end,
  },
}
