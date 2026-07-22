-- Neogit: интерактивный git-интерфейс (как magit в Emacs)
-- space+mg — открыть Neogit
return {
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
}
