-- Space+t+o → группа AI-дополнений
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>to"] = { desc = "Toggle AI" },
        ["<Leader>to1"] = { function() require("plugins.plugins.ai.state").toggle("supermaven") end, desc = "Toggle supermaven" },
        ["<Leader>to2"] = { function() require("plugins.plugins.ai.state").toggle("minuet") end, desc = "Toggle minuet" },
        ["<Leader>to0"] = { function() require("plugins.plugins.ai.state").disable_all() end, desc = "Disable both" },
      },
    },
  },
}
