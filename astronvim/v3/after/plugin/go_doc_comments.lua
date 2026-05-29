local ns = vim.api.nvim_create_namespace "user_go_doc_comments"

local function set_highlight()
  vim.api.nvim_set_hl(0, "UserGoDocCommentIdentifier", { fg = "#c7b99d" })
end

local function escape_pattern(value)
  return (value:gsub("([^%w])", "%%%1"))
end

local function declaration_name(line)
  return line:match "^%s*type%s+([%a_][%w_]*)"
    or line:match "^%s*func%s+([%a_][%w_]*)%s*%("
    or line:match "^%s*func%s*%b()%s*([%a_][%w_]*)%s*%("
    or line:match "^%s*const%s+([%a_][%w_]*)"
    or line:match "^%s*var%s+([%a_][%w_]*)"
end

local function highlight_doc_comment_name(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "go" then return end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for index, line in ipairs(lines) do
    local name = declaration_name(line)
    if name then
      local comment_index = index - 1

      while comment_index >= 1 and lines[comment_index]:match "^%s*//" do
        local comment = lines[comment_index]
        local match_start, match_end = comment:find("^%s*//%s*" .. escape_pattern(name) .. "%f[^%w_]")

        if match_start and match_end then
          local name_start = match_end - #name + 1
          vim.api.nvim_buf_set_extmark(bufnr, ns, comment_index - 1, name_start - 1, {
            end_col = match_end,
            hl_group = "UserGoDocCommentIdentifier",
          })
          break
        end

        comment_index = comment_index - 1
      end
    end
  end
end

set_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_highlight,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function(args) highlight_doc_comment_name(args.buf) end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "BufWritePost" }, {
  pattern = "*.go",
  callback = function(args) highlight_doc_comment_name(args.buf) end,
})
