-- Клавиша ` в go-файлах: убивает старые процессы, сохраняет и запускает проект.
-- Ищет main.go от корня проекта, если не находит — запускает go run . из текущей папки.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      go_run = {
        {
          event = "FileType",
          pattern = "go",
          callback = function()
            local function kill_go_processes()
              vim.fn.system "pkill -f 'go run'"
              vim.fn.system "pkill -f 'go-build'"
            end

            local function find_main_relative_path()
              local cwd = vim.fn.getcwd()
              local handle = io.popen('find "' .. cwd .. '" -name "main.go" -type f 2>/dev/null | head -n 1')
              if handle then
                local full_path = handle:read "*a"
                handle:close()
                full_path = full_path:gsub("\n", "")
                if full_path ~= "" then return vim.fn.fnamemodify(full_path, ":.") end
              end
            end

            vim.keymap.set("n", "`", function()
              vim.cmd "silent write"
              kill_go_processes()
              local main_path = find_main_relative_path()
              if main_path then
                vim.cmd('TermExec cmd="clear && go run ' .. main_path .. '"')
              else
                vim.cmd 'TermExec cmd="clear && go run ."'
              end
            end, { buffer = true, desc = "Kill and run Go project" })
          end,
        },
      },
    },
  },
}
