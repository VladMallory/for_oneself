-- Абсолютные номера строк: не прыгают при перемещении курсора.
-- По умолчанию AstroNvim включает относительные номера (relativenumber),
-- из-за чего строка под курсором всегда 0, а остальные — расстояние до неё.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = false,
      },
    },
  },
}
