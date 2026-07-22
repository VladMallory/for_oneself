-- space+3 — запуск go test ./... в терминале
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>3"] = {
          function() vim.cmd 'TermExec cmd="clear && go test ./..."' end,
          desc = "Run Go tests",
        },
      },
    },
  },
}
