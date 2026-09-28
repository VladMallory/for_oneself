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
              local old_lines = vim.split(original, "\n", { plain = true })
              local new_lines = vim.split(formatted, "\n", { plain = true })
              if #new_lines > 0 and new_lines[#new_lines] == "" then table.remove(new_lines) end
              -- Точечная замена вместо set_lines(0,-1): меняем только
              -- изменившийся диапазон, чтобы extmarks lensline на остальных
              -- строках выжили и код не прыгал весь целиком.
              local first = 1
              while first <= #old_lines
                and first <= #new_lines
                and old_lines[first] == new_lines[first]
              do
                first = first + 1
              end
              local old_last, new_last = #old_lines, #new_lines
              while old_last >= first
                and new_last >= first
                and old_lines[old_last] == new_lines[new_last]
              do
                old_last = old_last - 1
                new_last = new_last - 1
              end
              local replacement = {}
              for i = first, new_last do
                table.insert(replacement, new_lines[i])
              end
              -- Сохраняем курсор/view, иначе после set_lines экран прыгает,
              -- что вместе с перерисовкой lensline выглядит как "код ходит".
              local view = vim.fn.winsaveview()
              vim.api.nvim_buf_set_lines(buf, first - 1, old_last, false, replacement)
              pcall(vim.fn.winrestview, view)
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
