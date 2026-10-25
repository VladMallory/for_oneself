-- noice.nvim — красивая командная строка, всплывающие уведомления и сообщения.
--
-- Заменяет стандартную нижнюю командную строку (cmdline) на плавающее окно,
-- а уведомления vim.notify / сообщения — на стильные всплывашки с иконками.
-- Также показывает сбоку прогресс LSP-клиентов, установку Mason и т.д.
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    -- nui.nvim уже идёт как зависимость snacks.nvim, но указываем явно для надёжности.
    "MunifTanjim/nui.nvim",
    -- маршрутизация логов/сообщений
    "rcarriga/nvim-notify",
  },
  opts = {
    lsp = {
      -- перекрываем сообщения LSP и показываем прогресс в статуслайне/winbar
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      -- AstroLSP уже красиво рисует hover и signature_help,
      -- поэтому Noice их не перекрывает (иначе конфликт при загрузке).
      hover = { enabled = false },
      signature = { enabled = false },
    },
    -- маршрутизация разных типов сообщений
    routes = {
      {
        -- Скрываем LSP-прогресс от null-ls: всплывашки вида
        -- "golangci_lint (0%) diagnostics_on_save null-ls" внизу справа
        -- при каждом сохранении Go-файла. Сам линтер продолжает работать.
        filter = {
          event = "lsp",
          kind = "progress",
          find = "null%-ls",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" }, -- сообщения "written" при сохранении
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini", -- короткие сообщения в мини-окошке
      },
      {
        -- Скрываем сообщения null-ls (none-ls), если приходят через vim.notify
        -- с префиксом "[null-ls] ...". Сам линтер продолжает работать.
        filter = {
          event = "notify",
          find = "null%-ls",
        },
        opts = { skip = true },
      },
    },
    presets = {
      bottom_search = true, -- поиск (/) в стильном окне снизу
      command_palette = false, -- : внизу, как стандартно в vim
      long_message_to_split = true, -- длинные сообщения в split
      inc_rename = true, -- красивое переименование
      lsp_doc_border = true, -- рамка у LSP-доков
    },
  },
}
