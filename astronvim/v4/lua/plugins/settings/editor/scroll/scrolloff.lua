-- scrolloff = 5: курсор всегда на расстоянии минимум 5 строк от края экрана.
-- Без этого курсор упирается в самый верх/низ — не видно контекста.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        scrolloff = 5,
      },
    },
  },
}
