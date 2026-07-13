return {
  {
    "AstroNvim/astrolsp",
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
            },
          },
        },
      },
    },
  },
}
