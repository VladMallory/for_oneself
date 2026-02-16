return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>3"] = {
          function() vim.lsp.buf.rename() end,
          desc = "LSP Rename",
        },
      },
    },
  },
}
