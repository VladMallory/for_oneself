-- space+3 — запуск go test ./... в терминале
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<Leader>3"] = {
          -- Успех — только `exit=0`, провал — весь вывод целиком.
          function()
            vim.cmd [[TermExec cmd="clear && f=$(mktemp) && go test ./... > $f 2>&1; c=$?; if [ $c -eq 0 ]; then echo exit=0; else cat $f; echo exit=$c; fi; rm -f $f"]]
          end,
          desc = "Run Go tests",
        },
      },
    },
  },
}
