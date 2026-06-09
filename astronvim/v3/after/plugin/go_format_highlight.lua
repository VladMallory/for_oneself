local ns = vim.api.nvim_create_namespace("user_go_format_specifiers")
local format_pattern = "%%([+#%%%- 0]*)(%d*)(%.?)(%d*)([vTtbcdoOqxXUeEfFgGspw])"

vim.api.nvim_set_hl(0, "UserGoFormatSpec", { fg = "#d3869b", bold = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "UserGoFormatSpec", { fg = "#d3869b", bold = true })
  end,
})

local function highlight_format_specifiers(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "go" then return end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "go")
  if not ok or not parser then
    vim.defer_fn(function()
      highlight_format_specifiers(bufnr)
    end, 200)
    return
  end

  local tree = parser:parse()[1]
  if not tree then return end

  local root = tree:root()
  if not root then return end

  local ok, query = pcall(vim.treesitter.query.parse, "go", [[
    (interpreted_string_literal) @string
  ]])
  if not ok or not query then return end

  for _, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local text = vim.treesitter.get_node_text(node, bufnr)
    if not text then break end

    local start_row, start_col, _, _ = node:range()

    local pos = 1
    while pos <= #text do
      local s, e = text:find(format_pattern, pos)
      if not s then break end
      vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col + s - 1, {
        end_col = start_col + e,
        hl_group = "UserGoFormatSpec",
        priority = 200,
      })
      pos = e + 1
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args)
    vim.defer_fn(function()
      highlight_format_specifiers(args.buf)
    end, 50)
  end,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  callback = function()
    if vim.bo.filetype == "go" then
      highlight_format_specifiers(vim.api.nvim_get_current_buf())
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.go",
  callback = function(args)
    highlight_format_specifiers(args.buf)
  end,
})
