-- Действия: клавиши, привязанные к go-буферам
return {
  { import = "plugins.go.actions.go_run" },
  { import = "plugins.go.actions.go_test" },
  { import = "plugins.go.actions.go_test_cover" },
  { import = "plugins.go.actions.go_coverage_toggle" },
  { import = "plugins.go.actions.terminate" },
  { import = "plugins.go.actions.fill_struct" }
}
