return {
  {
    "AstroNvim/astrocore",
    init = function()
      local group = vim.api.nvim_create_augroup("user_go_format", { clear = true })

      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      local function format_via_stdin(cmd, input)
        local result = vim.fn.system("PATH=" .. mason_bin .. ":$PATH " .. cmd, input)
        if vim.v.shell_error == 0 then
          if result:find("^level=") then
            return input
          end
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

          pcall(vim.api.nvim_buf_clear_namespace, buf, vim.api.nvim_create_namespace("lensline"), 0, -1)

          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local input = table.concat(lines, "\n")

          local filepath = vim.api.nvim_buf_get_name(buf)
          local result = format_via_stdin(
            string.format(
              "golangci-lint fmt --stdin -E gofumpt -E goimports -E golines %s",
              filepath
            ),
            input
          )

          apply_formatted(buf, input, result)
        end,
      })
    end,
  },
}
