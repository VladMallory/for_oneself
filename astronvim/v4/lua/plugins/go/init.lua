-- lazy.nvim import сканирует только один уровень вложенности.
-- init.lua нужен в каждой подпапке, чтобы подключить файлы глубже.
return {
  { import = "plugins.go.actions" },
  { import = "plugins.go.keymap" },
  { import = "plugins.go.plugin" },
  { import = "plugins.go.serve" },
  { import = "plugins.go.visual" },
}
