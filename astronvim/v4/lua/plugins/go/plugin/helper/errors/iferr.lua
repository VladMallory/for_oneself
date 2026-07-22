-- Генерация if err != nil { return ... } по позиции курсора.
-- iferr — утилита из mason, вычисляет возвращаемые типы функции
-- и подставляет правильные zero-values.
-- Клавиша: space + 5
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>5"] = {
          function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local offset = vim.fn.line2byte(row) + col
            local file = vim.fn.expand "%:p"
            local command = "iferr -pos " .. offset .. " < " .. vim.fn.shellescape(file)
            local output = vim.fn.system(command)

            if vim.v.shell_error ~= 0 then
              vim.notify("iferr failed", vim.log.levels.ERROR)
              return
            end

            vim.api.nvim_put(vim.split(output, "\n"), "l", true, true)
          end,
          desc = "Generate if err block",
        },
      },
    },
  },
}
