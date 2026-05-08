local go_bin = vim.fn.expand "$HOME/go/bin"

return {
  {
    "simondrake/gomodifytags",
    ft = "go",
    keys = {
      {
        "<leader>6",
        function() require("gomodifytags").GoAddTags "json" end,
        ft = "go",
        desc = "Add JSON struct tags",
      },
    },
    init = function()
      if vim.fn.executable "gomodifytags" == 0 and vim.fn.isdirectory(go_bin) == 1 then
        vim.env.PATH = go_bin .. ":" .. vim.env.PATH
      end
    end,
    opts = {
      parse = { enabled = true, separator = "--" },
    },
    config = function(_, opts)
      require("gomodifytags").setup(opts)

      local function command_opts(cmd)
        if cmd.args:find("%s%-%-%s") then return cmd.args end
      end

      vim.api.nvim_create_user_command("GoAddTags", function(cmd)
        require("gomodifytags").GoAddTags(cmd.fargs[1], command_opts(cmd))
      end, { nargs = "+" })

      vim.api.nvim_create_user_command("GoRemoveTags", function(cmd)
        require("gomodifytags").GoRemoveTags(cmd.fargs[1], command_opts(cmd))
      end, { nargs = "+" })
    end,
  },
}
