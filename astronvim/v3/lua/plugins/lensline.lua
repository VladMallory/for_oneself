return {
  {
    "oribarilan/lensline.nvim",
    tag = "2.1.0",
    event = "LspAttach",
    config = function()
      require("lensline").setup {
        profiles = {
          {
            name = "jetbrains",
            providers = {
              {
                name = "usages",
                enabled = true,
                include = { "impls", "refs" },
                breakdown = true,
                show_zero = true,
                labels = {
                  impls = "implementations",
                  refs = "references",
                },
                icon_for_single = "",
                inner_separator = " | ",
              },
            },
            style = {
              prefix = "| ",
              separator = " | ",
              placement = "above",
              highlight = "Comment",
              use_nerdfont = false,
              render = "all",
            },
          },
        },
      }
    end,
  },
}
