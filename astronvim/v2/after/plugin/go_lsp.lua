local go_filetypes = {
  go = true,
  gomod = true,
  gowork = true,
  gotmpl = true,
}

local function ensure_gopls(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].buftype ~= "" or not go_filetypes[vim.bo[bufnr].filetype] then return end

  local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
  if #clients > 0 then return end

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" and go_filetypes[vim.bo[bufnr].filetype] then
      pcall(vim.cmd, "LspStart gopls")
    end
  end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  pattern = { "*.go", "go.mod", "go.work", "go.sum" },
  callback = function(args) ensure_gopls(args.buf) end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function(args) ensure_gopls(args.buf) end,
})
