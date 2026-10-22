-- Иконки в Neo-tree (Space + e).
-- Neo-tree берёт их из mini.icons; здесь точечно подменяем нужные.
--
-- Go: варианты глифов из Nerd Fonts (кодпоинты сверены с glyphnames.json):
--   seti-go        U+E627  — текущая, «запомнена» (стоит сейчас)
--   custom-go      U+E626
--   dev-go         U+E724
--   md-language_go U+F07D3 — «квадратный» гофер из Material Design (был по умолчанию)
-- Чтобы попробовать другой — поменяй GO_VARIANT ниже на seti/custom/dev/md.
-- Пишем через nr2char, чтобы глиф не терялся при копировании/правках файла.
local GO_VARIANTS = {
  seti = 0xE627,
  custom = 0xE626,
  dev = 0xE724,
  md = 0xF07D3,
}
local GO_VARIANT = "seti" -- <<< какой вариант сейчас включён
-- История (2026-10-22):
--   "md"   = U+F07D3 — дефолт mini.icons, «квадратный» гофер (не понравился);
--   "seti" = U+E627  — этот понравился, вернули его;
--   ещё есть "custom" = U+E626 и "dev" = U+E724, если захочется попробовать.
local GO_ICON = vim.fn.nr2char(GO_VARIANTS[GO_VARIANT])
local GO_HIGHLIGHT = "MiniIconsAzure" -- синий #00ADD8 (группа из mini.icons)

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- при icons_enabled = false (ascii) ничего не подменяем
    if vim.g.icons_enabled == false then return opts end

    opts.default_component_configs = opts.default_component_configs or {}
    local icon = opts.default_component_configs.icon or {}
    opts.default_component_configs.icon = icon

    -- Сохраняем штатный провайдер (mini.icons) и оборачиваем его:
    -- остальные иконки остаются как были, меняется только Go.
    local base = icon.provider
    icon.provider = function(component, node, state)
      if base then component = base(component, node, state) or component end
      if node.type == "file" and node.name:match "%.go$" then
        component.text = GO_ICON
        component.highlight = GO_HIGHLIGHT
      end
      return component
    end

    return opts
  end,
}
