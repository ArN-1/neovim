-- ============================================================================
-- init.lua - Main Configuration
-- ============================================================================

vim.opt.rtp:append(vim.fn.expand("~/nixos-config/modules/user/neovim"))

-- Essential options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.updatetime = 300
vim.opt.timeoutlen = 300 -- Faster timeout
vim.opt.clipboard = "unnamedplus"
vim.opt.conceallevel = 0
vim.opt.fileencoding = "utf-8"
vim.opt.mouse = "a"
vim.opt.pumheight = 15 -- More completion items visible
vim.opt.showmode = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Load modules
local modules = {
  "keymaps",
  "cmp",
  "lsp",
  "ui",
  "formatter",
  "dap",
}

for _, module in ipairs(modules) do
  pcall(require, module)
end

-- Treesitter setup
local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if ok then
  treesitter.setup({
    auto_install = false,
    ensure_installed = {},
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    indent = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  })
end

-- Python settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    -- Ensure snippets are available
    require('luasnip').filetype_extend("python", {"python"})
  end,
})

-- Force snippet loading for all filetypes on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Ensure all snippets are loaded
    require("luasnip.loaders.from_vscode").lazy_load()
    -- Refresh snippet availability
    vim.schedule(function()
      require('luasnip').refresh_notify("python")
    end)
  end,
})