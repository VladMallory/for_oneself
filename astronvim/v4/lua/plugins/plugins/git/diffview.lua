-- Diffview: сравнение изменений, история файла
-- space+gd — открыть diff текущих изменений
-- space+gD — закрыть diffview
-- space+gh — история изменений текущего файла
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewClose", "DiffviewFileHistory", "DiffviewOpen" },
  keys = {
    { "<Leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
    { "<Leader>gD", "<Cmd>DiffviewClose<CR>", desc = "Close Diffview" },
    { "<Leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
  },
}
