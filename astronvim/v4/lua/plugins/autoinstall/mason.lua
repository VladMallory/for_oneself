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
        "gotests",

        -- rust
        "rust-analyzer",
        
        -- zig
        -- zls ставится системно через Homebrew (brew install zls) и уже есть в PATH,
        -- поэтому Mason его не трогаем. Если всё-таки нужен Mason — писать просто "zls":
        -- версионных имён вида "zls@0.17.0" в реестре Mason больше нет.
        -- "zls",
      })
    end,
  },
}
