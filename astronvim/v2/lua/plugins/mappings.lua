return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>3"] = {
          function() vim.lsp.buf.rename() end,
          desc = "LSP Rename",
        },
        ["<Leader>4"] = {
          function()
            vim.cmd('TermExec cmd="/usr/local/go/bin/go test ./..."')
          end,
          desc = "Run Go tests",
        },
      },
    },
  },
}
