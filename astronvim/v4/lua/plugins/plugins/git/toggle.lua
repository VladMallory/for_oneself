-- space+g+v — скрыть/показать значки изменений в gutter
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>gv"] = {
          function() require("gitsigns").toggle_signs() end,
          desc = "Toggle Git signs",
        },
      },
    },
  },
}
