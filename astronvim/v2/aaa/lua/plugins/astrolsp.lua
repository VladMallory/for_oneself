---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },

    formatting = {
      format_on_save = {
        enabled = true,
      },
      timeout_ms = 1000,
    },

    config = {
      gopls = {
        settings = {
          gopls = {
            completeUnimported = true,
            staticcheck = true,
            usePlaceholders = true,
            gofumpt = true,
          },
        },
      },
    },
  },
}

