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

return {
  {
    "AstroNvim/astrocore",
    init = function()
      local group = vim.api.nvim_create_augroup("user_go_gopls", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
        group = group,
        pattern = { "*.go", "go.mod", "go.work", "go.sum" },
        callback = function(args) ensure_gopls(args.buf) end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "go", "gomod", "gowork", "gotmpl" },
        callback = function(args) ensure_gopls(args.buf) end,
      })

      local function format_via_stdin(cmd, input)
        local result = vim.fn.system(cmd, input)
        if vim.v.shell_error == 0 then
          return result
        end
        return input
      end

      local function apply_formatted(buf, original, formatted)
        if formatted == original then return end
        local new_lines = vim.split(formatted, "\n", { plain = true })
        if #new_lines > 0 and new_lines[#new_lines] == "" then
          table.remove(new_lines)
        end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        pattern = { "*.go" },
        callback = function(args)
          local buf = args.buf

          -- Очищаем extmarks lensline перед изменением буфера,
          -- чтобы виртуальные строки не накапливались
          pcall(vim.api.nvim_buf_clear_namespace, buf, vim.api.nvim_create_namespace("lensline"), 0, -1)

          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local input = table.concat(lines, "\n")

          -- gofumpt всегда, даже без .golangci.yml
          local result = format_via_stdin("gofumpt", input)
          -- golangci-lint fmt: добавит goimports и кастомные rules из конфига
          result = format_via_stdin("golangci-lint fmt --stdin", result)

          apply_formatted(buf, input, result)
        end,
      })
    end,
  },
}
