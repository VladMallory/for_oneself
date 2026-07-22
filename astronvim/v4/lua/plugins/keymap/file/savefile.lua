-- 2 — сохранить файл. <Cmd>write<CR> работает без выхода из режима.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["2"] = { "<Cmd>write<CR>", desc = "Save file" },
      },
    },
  },
}
