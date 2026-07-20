return {
  {
    "AstroNvim/astrocore",
    init = function()
      local group = vim.api.nvim_create_augroup("user_go_lsp", { clear = true })

      local function ensure_gopls(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        if vim.bo[bufnr].buftype ~= "" then return end
        if not vim.startswith(vim.bo[bufnr].filetype, "go") then return end

        local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
        if #clients > 0 then return end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then return end
          if vim.bo[bufnr].buftype ~= "" then return end
          if not vim.startswith(vim.bo[bufnr].filetype, "go") then return end
          pcall(vim.cmd, "LspStart gopls")
        end)
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        group = group,
        pattern = { "*.go", "go.mod", "go.work", "go.sum" },
        callback = function(args) ensure_gopls(args.buf) end,
      })
    end,
  },
}
