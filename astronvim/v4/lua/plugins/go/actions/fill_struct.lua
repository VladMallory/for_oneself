-- <Leader>7 в Go: кастомное меню выбор действия LSP.
-- Показывает только: source.addTest (тесты) и refactor.rewrite (заполнение структуры).
-- Использует встроенное vim.ui.select Neovim.
-- apply=true: применяет действие сразу, без повторного окна подтверждения.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>7"] = {
          function()
            -- Два действия, которые доступны в gopls
            local items = {
              "source.addTest — add test",
              "refactor.rewrite — fill struct",
            }
            -- Показываем меню выбора
            vim.ui.select(items, {
              prompt = "Go: code actions",
            }, function(choice)
              if not choice then return end
              local only = choice:match "source.addTest" and "source.addTest" or "refactor.rewrite"
              -- apply=true — применить сразу, без подтверждения/доп. окна
              vim.lsp.buf.code_action {
                context = { only = { only } },
                apply = true,
              }
            end)
          end,
          desc = "Go: code actions (test / fill struct)",
        },
      },
    },
  },
}
