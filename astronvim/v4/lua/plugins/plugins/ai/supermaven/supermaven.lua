return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<C-l>",
      },
    },
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
      local state = require("plugins.plugins.ai.state").load()
      if not state.supermaven then
        vim.cmd("SupermavenStop")
      end
    end,
  },
}
