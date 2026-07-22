-- Мягкий перенос длинных строк без изменения файла.
-- wrap — перенос по словам, linebreak — не разрывает слова,
-- breakindent — отступ продолжения строки, showbreak — маркер ↪
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        wrap = true,
        linebreak = true,
        breakindent = true,
        breakindentopt = "shift:0,sbr",
        showbreak = "↪  ",
      },
    },
  },
}
