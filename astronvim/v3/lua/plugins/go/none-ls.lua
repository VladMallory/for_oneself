local none_ls_configured = false

return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      if none_ls_configured then return end
      none_ls_configured = true

      local null_ls = require "null-ls"

      opts.sources = require("astrocore").list_insert_unique(opts.sources or {}, {
        null_ls.builtins.diagnostics.golangci_lint,
      })
    end,
  },
}
