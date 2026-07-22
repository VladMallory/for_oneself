-- Клавиша ` в rust-файлах: убивает старые процессы, сохраняет и запускает cargo run.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      rust_run = {
        {
          event = "FileType",
          pattern = "rust",
          callback = function()
            local function kill_cargo_processes() vim.fn.system "pkill -f 'cargo run'" end

            vim.keymap.set("n", "`", function()
              vim.cmd "silent write"
              kill_cargo_processes()
              vim.cmd 'TermExec cmd="clear && cargo run"'
            end, { buffer = true, desc = "Kill and run Rust project" })
          end,
        },
      },
    },
  },
}
