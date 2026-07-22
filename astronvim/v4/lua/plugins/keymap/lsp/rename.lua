-- space+4 — переименовать символ во всём проекте (LSP rename)
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>4"] = { vim.lsp.buf.rename, desc = "LSP Rename" },
      },
    },
  },
}
