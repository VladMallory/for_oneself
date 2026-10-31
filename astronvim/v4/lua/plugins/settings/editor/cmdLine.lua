-- ; вместо Shift+: для входа в командную строку.
-- В обычном режиме ; по умолчанию повторяет f/t — эта привязка заменяет его.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        [";"] = { ":", desc = "Enter command-line mode" },
      },
      v = {
        [";"] = { ":", desc = "Enter command-line mode" },
      },
    },
  },
}
