return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      {
        "]h",
        function() require("gitsigns").nav_hunk "next" end,
        desc = "Next Git hunk",
      },
      {
        "[h",
        function() require("gitsigns").nav_hunk "prev" end,
        desc = "Previous Git hunk",
      },
      {
        "<Leader>gr",
        function() require("gitsigns").reset_hunk() end,
        desc = "Reset Git hunk",
      },
      {
        "<Leader>gp",
        function() require("gitsigns").preview_hunk() end,
        desc = "Preview Git hunk",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<Leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
      { "<Leader>gD", "<Cmd>DiffviewClose<CR>", desc = "Close Diffview" },
      { "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<Leader>mg", "<Cmd>Neogit<CR>", desc = "Open Neogit" },
    },
    opts = {
      integrations = {
        diffview = true,
      },
    },
  },
}
