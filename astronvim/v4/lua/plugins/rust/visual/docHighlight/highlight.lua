-- Подсветка вхождений (document highlight) для Rust без мерцания при печати.
-- Работает только в normal mode, в insert mode очищается.
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      rust_doc_highlight = {
        {
          event = "CursorHold",
          pattern = "rust",
          callback = function()
            if vim.api.nvim_get_mode().mode ~= "i" then
              pcall(vim.lsp.buf.document_highlight)
            end
          end,
        },
        {
          event = "CursorMoved",
          pattern = "rust",
          callback = function()
            pcall(vim.lsp.buf.clear_references)
          end,
        },
        {
          event = "InsertEnter",
          pattern = "rust",
          callback = function()
            pcall(vim.lsp.buf.clear_references)
          end,
        },
      },
    },
  },
}
