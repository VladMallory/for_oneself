-- Arch Linux ASCII логотип на стартовом экране
return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          "                   -`                    ",
          "                  .o+`                   ",
          "                 `ooo/                   ",
          "                `+oooo:                  ",
          "               `+oooooo:                 ",
          "               -+oooooo+:                ",
          "             `/:-:++oooo+:               ",
          "            `/++++/+++++++:              ",
          "           `/++++++++++++++:             ",
          "          `/+++ooooooooooooo/`           ",
          "         ./ooosssso++osssssso+`          ",
          "        .oossssso-````/ossssss+`         ",
          "       -osssssso.      :ssssssso.        ",
          "      :osssssss/        osssso+++.       ",
          "     /ossssssss/        +ssssooo/-       ",
          "   `/ossssso+/:-        -:/+osssso+-     ",
          "  `+sso+:-`                 `.-/+oso:    ",
          " `++:.                           `-/+/   ",
          " .`                                 `/   ",
          "",
          "           A R C H   L I N U X            ",
        }, "\n"),
      },
    },
  },
}
