-- Навигация по git-изменениям: ]h / [h, reset, preview
-- space+gr — сбросить hunk
-- space+gp — показать hunk
return {
  "lewis6991/gitsigns.nvim",
  keys = {
    { "]h", function() require("gitsigns").nav_hunk "next" end, desc = "Next Git hunk" },
    { "[h", function() require("gitsigns").nav_hunk "prev" end, desc = "Previous Git hunk" },
    { "<Leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset Git hunk" },
    { "<Leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Git hunk" },
  },
}
