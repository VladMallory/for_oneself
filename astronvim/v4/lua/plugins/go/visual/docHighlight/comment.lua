-- Подсвечивает имя типа/функции в Go doc-комментариях.
-- Если над функцией написан // MyFunc does X — MyFunc подсветится.
local ns = vim.api.nvim_create_namespace "user_go_doc_comments"

vim.api.nvim_set_hl(0, "UserGoDocCommentIdentifier", { fg = "#c7b99d" })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() vim.api.nvim_set_hl(0, "UserGoDocCommentIdentifier", { fg = "#c7b99d" }) end,
})

local function declaration_name(line)
  return line:match "^%s*type%s+([%a_][%w_]*)"
    or line:match "^%s*func%s+([%a_][%w_]*)%s*%("
    or line:match "^%s*func%s*%b()%s*([%a_][%w_]*)%s*%("
    or line:match "^%s*const%s+([%a_][%w_]*)"
    or line:match "^%s*var%s+([%a_][%w_]*)"
end

local function highlight(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "go" then return end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for index, line in ipairs(lines) do
    local name = declaration_name(line)
    if name then
      local comment_index = index - 1
      while comment_index >= 1 and lines[comment_index]:match "^%s*//" do
        local comment = lines[comment_index]
        local prefix = comment:match "^(%s*//%s*)"
        if prefix then
          local after_prefix = comment:sub(#prefix + 1)
          if after_prefix:sub(1, #name) == name then
            vim.api.nvim_buf_set_extmark(bufnr, ns, comment_index - 1, #prefix, {
              end_col = #prefix + #name,
              hl_group = "UserGoDocCommentIdentifier",
            })
            break
          end
        end
        comment_index = comment_index - 1
      end
    end
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "BufWritePost" }, {
  pattern = "*.go",
  callback = function(args) highlight(args.buf) end,
})

-- Пройтись по уже открытым go-буферам
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  highlight(buf)
end

return {}
