-- Отключаем format_on_save для Go (форматируем через BufWritePre в format.lua)
local astrolsp = require("astrolsp")
if astrolsp and astrolsp.config then
  astrolsp.config.formatting.format_on_save.ignore_filetypes = { "go" }
end
