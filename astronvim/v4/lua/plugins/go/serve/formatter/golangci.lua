-- Единый форматтер для Go через golangci-lint.
-- Запускается на BufWritePre, до сохранения файла на диск.
-- -E gofumpt:   строгий gofmt (пробелы, группировка)
-- -E goimports: сортировка и группировка импортов
-- -E golines:   перенос длинных строк
-- PATH включает mason/bin, чтобы golangci-lint был найден.
-- gopls-форматтер отключён в go/serve/gopls.lua — иначе он ломает gofumpt.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_golangci_fmt = {
        {
          event = "BufWritePre",
          pattern = "*.go",
          callback = function(args)
            local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"

            local function format_via_stdin(cmd, input)
              local result = vim.fn.system("PATH=" .. mason_bin .. ":$PATH " .. cmd, input)
              if vim.v.shell_error == 0 and not result:find "^level=" then return result end
              return input
            end

            local function apply_formatted(buf, original, formatted)
              if formatted == original then return end
              local new_lines = vim.split(formatted, "\n", { plain = true })
              if #new_lines > 0 and new_lines[#new_lines] == "" then table.remove(new_lines) end
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
            end

            local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
            local input = table.concat(lines, "\n")
            local filepath = vim.api.nvim_buf_get_name(args.buf)
            local result = format_via_stdin(
              ("golangci-lint fmt --stdin -E gofumpt -E goimports -E golines %s"):format(filepath), input
            )
            apply_formatted(args.buf, input, result)
          end,
        },
      },
    },
  },
}
