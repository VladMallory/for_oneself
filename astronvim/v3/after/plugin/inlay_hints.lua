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
            },
          },
        },
      },
    },
  },
}
