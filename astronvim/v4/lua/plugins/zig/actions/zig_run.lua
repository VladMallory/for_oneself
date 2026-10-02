-- Клавиша ` в zig-файлах: убивает старые процессы, сохраняет и запускает проект.
-- Ищет main.zig от корня проекта, если не находит — запускает zig run для текущего файла.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      zig_run = {
        {
          event = "FileType",
          pattern = "zig",
          callback = function()
            local function kill_zig_processes()
              vim.fn.system "pkill -f 'zig run'"
              vim.fn.system "pkill -f 'zig-build'"
            end

            local function find_main_relative_path()
              local cwd = vim.fn.getcwd()
              local handle = io.popen('find "' .. cwd .. '" -name "main.zig" -type f 2>/dev/null | head -n 1')
              if handle then
                local full_path = handle:read "*a"
                handle:close()
                full_path = full_path:gsub("\n", "")
                if full_path ~= "" then return vim.fn.fnamemodify(full_path, ":.") end
              end
            end

            vim.keymap.set("n", "`", function()
              vim.cmd "silent write"
              kill_zig_processes()
              local main_path = find_main_relative_path()
              if main_path then
                vim.cmd('TermExec cmd="clear && zig run ' .. main_path .. '"')
              else
                vim.cmd('TermExec cmd="clear && zig run ' .. vim.fn.expand "%:." .. '"')
              end
            end, { buffer = true, desc = "Kill and run Zig project" })
          end,
        },
      },
    },
  },
}
