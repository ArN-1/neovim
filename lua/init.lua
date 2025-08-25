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
-- Updated completeopt for better cmp experience
vim.opt.completeopt = { "menu", "menuone", "noinsert" }

-- Load modules in specific order for proper initialization
local modules = {
  "keymaps",
  "lsp",        -- Load LSP first to setup capabilities and on_attach
  "ui",
  "formatter",
  "dap",
}

-- Enhanced module loading with better error handling
for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify(string.format("Failed to load module '%s': %s", module, err), vim.log.levels.WARN)
  end
end

-- Setup CMP after LSP is initialized but before other modules that might depend on it
vim.schedule(function()
  local cmp_config_ok, cmp_config = pcall(require, "config.cmp")
  if cmp_config_ok then
    cmp_config.setup()
    
    -- Optional: Setup keymaps for CMP utilities
    vim.keymap.set("n", "<leader>tc", cmp_config.toggle, { desc = "Toggle Completion", silent = true })
    vim.keymap.set("n", "<leader>tg", cmp_config.toggle_ghost_text, { desc = "Toggle Ghost Text", silent = true })
    vim.keymap.set("n", "<leader>tp", cmp_config.toggle_copilot, { desc = "Toggle Copilot", silent = true })
    
    vim.notify("CMP configuration loaded successfully", vim.log.levels.INFO)
  else
    vim.notify("Failed to load CMP configuration", vim.log.levels.ERROR)
  end
end)

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

-- Enhanced Python settings with better completion support
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    
    -- Enhanced snippet loading for Python
    local luasnip_ok, luasnip = pcall(require, 'luasnip')
    if luasnip_ok then
      luasnip.filetype_extend("python", {"python"})
      -- Refresh snippets for current buffer
      vim.schedule(function()
        luasnip.refresh_notify("python")
      end)
    end
    
    -- Python-specific completion settings
    local cmp_ok, cmp = pcall(require, "cmp")
    if cmp_ok then
      cmp.setup.buffer({
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500, keyword_length = 2 },
          { name = "path", priority = 300 },
        })
      })
    end
  end,
})

-- Enhanced snippet loading with better error handling
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(function()
      local luasnip_ok, luasnip = pcall(require, "luasnip")
      if luasnip_ok then
        -- Load all snippet formats
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load()
        
        -- Configure LuaSnip
        luasnip.config.setup({
          history = true,
          updateevents = "TextChanged,TextChangedI",
          delete_check_events = "TextChanged",
          enable_autosnippets = true,
        })
        
        -- Refresh snippets for all filetypes
        luasnip.refresh_notify()
      end
    end)
  end,
})

-- Additional autocommands for better completion experience
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    -- Ensure completion is available for all buffers
    vim.schedule(function()
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        cmp.setup.buffer({ enabled = true })
      end
    end)
  end,
})

-- Performance optimization: lazy load heavy completion sources
vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    -- Load additional completion sources on first insert
    pcall(require, "cmp_buffer")
    pcall(require, "cmp_path")
    pcall(require, "cmp_calc")
    pcall(require, "cmp_emoji")
  end,
})

-- LSP-specific completion enhancements (removed since it's now handled in lsp.lua)
-- The enhanced lsp.lua now handles all LSP-specific autocommands and setups