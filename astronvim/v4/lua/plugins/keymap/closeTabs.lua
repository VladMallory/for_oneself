-- 0 — закрыть все вкладки (буферы) кроме активной.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["0"] = {
          function() require("astrocore.buffer").close_all(true) end,
          desc = "Close all buffers except current",
        },
      },
    },
  },
}
