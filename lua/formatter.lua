-- lua/formatter.lua
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    python = { "black", "isort" },
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },
  
  -- Format on save
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  
  -- Format after save for slow formatters
  format_after_save = {
    lsp_fallback = true,
  },
})

-- Manual format keymap
vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format file or range (in visual mode)" })

-- Setup linter
local lint = require("lint")
lint.linters_by_ft = {
  python = { "ruff" },
}

-- Auto-lint on save and text change
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  callback = function()
    lint.try_lint()
  end,
})