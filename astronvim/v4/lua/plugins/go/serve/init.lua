-- Сервисы: LSP, форматтеры, линтеры и прочие инструменты для go
return {
  { import = "plugins.go.serve.formatter" },
  { import = "plugins.go.serve.gopls" },
  { import = "plugins.go.serve.inlayHints" },
  { import = "plugins.go.serve.lensline" },
}
