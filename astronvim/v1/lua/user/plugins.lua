return {
  -- Существующий плагин gruvbox.nvim
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,  -- чтобы тема грузилась первой
    config = function()
      -- здесь можно указать опциональные настройки темы
      require("gruvbox").setup({
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = false,
          comments = true,
          operators = false,
          folds = true,
        },
        contrast = "soft",    -- можно выбрать "hard", "medium", "soft"
        palette_overrides = {},
      })
    end,
  },
  
  -- Добавляем новые плагины здесь
  {
    "plugin-author/plugin-name",
    config = function()
      -- настройки плагина
    end,
  },
  
  -- Пример: плагин для работы с комментариями
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  
  -- Пример: плагин для подсветки цветов
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
  
  -- Пример: плагин без дополнительной конфигурации
  {
    "tpope/vim-surround",
  },
}
