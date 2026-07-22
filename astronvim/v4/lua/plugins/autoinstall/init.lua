-- Автоустановка инструментов через Mason.
-- При первом запуске (или :Lazy sync) недостающие пакеты ставятся автоматически.
return {
  { import = "plugins.autoinstall.mason" },
}
