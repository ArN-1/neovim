-- ============================================================================
-- lsp.lua - LSP Configuration
-- ============================================================================

local lspconfig = require('lspconfig')
local util = require('lspconfig.util')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enhanced capabilities for snippets
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" }
}

local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }

  -- Core mappings
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-h>', vim.lsp.buf.signature_help, bufopts) -- Changed from C-k to avoid conflict
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Workspace
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- LSP Servers
local servers = {
  basedpyright = {
    root_dir = util.root_pattern('pyproject.toml', 'setup.py', 'requirements.txt', '.git'),
    settings = {
      basedpyright = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
        },
      },
    },
  },
  tsserver = {
    root_dir = util.root_pattern("package.json", "tsconfig.json", ".git"),
  },
  html = {},
  cssls = {},
  emmet_ls = {},
  jsonls = {},
  rust_analyzer = {
    root_dir = util.root_pattern("Cargo.toml", ".git"),
  },
  gopls = {
    root_dir = util.root_pattern("go.mod", ".git"),
  },
  bashls = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
  nil_ls = {
    settings = {
      ['nil'] = {
        formatting = {
          command = { "nixpkgs-fmt" },
        },
      },
    },
  },
  solargraph = {
    root_dir = util.root_pattern("Gemfile", ".git"),
  },
  dockerls = {},
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
        },
      },
    },
  },
  marksman = {},
  sqls = {},
}

-- Setup all servers
for server, config in pairs(servers) do
  local setup_config = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
    on_attach = on_attach,
  }, config)
  
  lspconfig[server].setup(setup_config)
end

-- Final snippet test command
vim.api.nvim_create_user_command("TestTrySnippet", function()
  -- Jump to insert mode, type try, then expand
  vim.cmd("startinsert")
  vim.schedule(function()
    vim.api.nvim_feedkeys("try", "n", true)
    vim.schedule(function()
      local luasnip = require("luasnip")
      if luasnip.expandable() then
        luasnip.expand()
        print("✅ Try snippet expanded!")
      else
        print("❌ Try snippet not expandable")
      end
    end)
  end)
end, {})