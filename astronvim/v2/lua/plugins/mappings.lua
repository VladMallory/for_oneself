return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>3"] = {
          function()
            vim.cmd('TermExec cmd="go test ./..."')
          end,
          desc = "Run Go tests",
        },
        ["<Leader>4"] = {
          function() vim.lsp.buf.rename() end,
          desc = "LSP Rename",
        },
        ["2"] = {
          function()
            vim.cmd("write")
          end,
          desc = "Save file",
        },
      },
    },
  },
}
