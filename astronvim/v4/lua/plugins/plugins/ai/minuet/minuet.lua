return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    opts = {
      provider = "openai_fim_compatible",
      provider_options = {
        openai_fim_compatible = {
          api_key = "DEEPSEEK_API_KEY",
          name = "Deepseek",
          end_point = "https://api.deepseek.com/beta/completions",
          model = "deepseek-v4-flash",
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
      n_completions = 1,
      virtualtext = {
        keymap = {
          accept = "<C-l>",
          next = "<C-n>",
          prev = "<C-p>",
          dismiss = "<C-e>",
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)
      local state = require("plugins.plugins.ai.state").load()
      if state.minuet then
        vim.schedule(function()
          vim.cmd("Minuet virtualtext enable")
        end)
      end
    end,
  },
}
