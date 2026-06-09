return {
  "AstroNvim/astrolsp",
  opts = function(_, opts)
    opts.config = opts.config or {}
    opts.config["rust_analyzer"] = {
      settings = {
        ["rust-analyzer"] = {
          lens = {
            enable = false,
          },
        },
      },
    }
  end,
}
