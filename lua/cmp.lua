-- ~/.config/nvim/lua/config/cmp.lua - Enhanced CMP Configuration
local M = {}

-- Default configuration options
M.options = {
  enable = true,
  
  -- Source configurations with priorities and settings
  sources = {
    nvim_lsp = { 
      name = "nvim_lsp",
      priority = 1000,
      keyword_length = 1,
      group_index = 1,
      label = "[LSP]"
    },
    luasnip = { 
      name = "luasnip",
      priority = 750,
      keyword_length = 1,
      group_index = 1,
      label = "[Snippet]"
    },
    buffer = { 
      name = "buffer",
      priority = 500,
      keyword_length = 2,
      group_index = 2,
      label = "[Buffer]",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    path = { 
      name = "path",
      priority = 300,
      keyword_length = 1,
      group_index = 2,
      label = "[Path]"
    },
    copilot = { 
      name = "copilot",
      priority = 100,
      keyword_length = 1,
      group_index = 3,
      label = "[AI]"
    },
    calc = {
      name = "calc",
      priority = 150,
      keyword_length = 1,
      group_index = 3,
      label = "[Calc]"
    },
    emoji = {
      name = "emoji",
      priority = 100,
      keyword_length = 1,
      group_index = 3,
      label = "[Emoji]"
    }
  },
  
  -- Feature toggles
  copilot = true,
  autopairs = true,
  ghost_text = true,
  
  -- UI configurations
  window = {
    completion = {
      border = "rounded",
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      col_offset = -3,
      side_padding = 0,
    },
    documentation = {
      border = "rounded",
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
    },
  },
  
  -- Completion behavior
  completion = {
    completeopt = "menu,menuone,noinsert",
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
    keyword_length = 1,
  },
  
  -- Confirmation behavior
  confirmation = {
    default_behavior = require('cmp').ConfirmBehavior.Insert,
    get_commit_characters = function(commit_characters)
      return commit_characters
    end,
  },
  
  -- Performance settings
  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 500,
    confirm_resolve_timeout = 80,
    async_budget = 1,
    max_view_entries = 200,
  },
}

-- Icons for different completion item kinds
local kind_icons = {
  Text = "󰉿",
  Method = "󰆧",
  Function = "󰊕",
  Constructor = "",
  Field = "󰜢",
  Variable = "󰀫",
  Class = "󰠱",
  Interface = "",
  Module = "",
  Property = "󰜢",
  Unit = "󰑭",
  Value = "󰎠",
  Enum = "",
  Keyword = "󰌋",
  Snippet = "",
  Color = "󰏘",
  File = "󰈙",
  Reference = "󰈇",
  Folder = "󰉋",
  EnumMember = "",
  Constant = "󰏿",
  Struct = "󰙅",
  Event = "",
  Operator = "󰆕",
  TypeParameter = "",
  Copilot = "",
  Buffer = "",
  Path = "󰉋",
  Calc = "󰃬",
  Emoji = "󰞅",
}

-- Build sources array from configuration
local function build_sources()
  local sources = {}
  local enabled_sources = {}
  
  -- Collect enabled sources
  for source_name, config in pairs(M.options.sources) do
    if config.name then
      table.insert(enabled_sources, {
        name = config.name,
        priority = config.priority or 500,
        keyword_length = config.keyword_length or 1,
        group_index = config.group_index or 1,
        option = config.option,
      })
    end
  end
  
  -- Sort by priority (higher first)
  table.sort(enabled_sources, function(a, b)
    return a.priority > b.priority
  end)
  
  -- Group sources by group_index
  local grouped = {}
  for _, source in ipairs(enabled_sources) do
    local group = source.group_index or 1
    if not grouped[group] then
      grouped[group] = {}
    end
    
    table.insert(grouped[group], {
      name = source.name,
      keyword_length = source.keyword_length,
      option = source.option,
    })
  end
  
  -- Convert to cmp format
  for i = 1, 10 do -- Support up to 10 groups
    if grouped[i] then
      table.insert(sources, grouped[i])
    end
  end
  
  return sources
end

-- Enhanced tab completion with smarter behavior
local function tab_complete(fallback)
  local cmp = require("cmp")
  local luasnip = require("luasnip")
  
  if cmp.visible() then
    cmp.select_next_item()
  elseif luasnip.locally_jumpable(1) then
    luasnip.jump(1)
  else
    fallback()
  end
end

local function shift_tab_complete(fallback)
  local cmp = require("cmp")
  local luasnip = require("luasnip")
  
  if cmp.visible() then
    cmp.select_prev_item()
  elseif luasnip.locally_jumpable(-1) then
    luasnip.jump(-1)
  else
    fallback()
  end
end

-- Main setup function
function M.setup()
  if not M.options.enable then 
    return 
  end

  local cmp_ok, cmp = pcall(require, "cmp")
  if not cmp_ok then 
    vim.notify("nvim-cmp not found!", vim.log.levels.WARN)
    return 
  end

  -- Setup LuaSnip if available
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if luasnip_ok then
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
  end

  -- Main cmp setup
  cmp.setup({
    enabled = function()
      -- Disable in comments
      local context = require("cmp.config.context")
      if vim.api.nvim_get_mode().mode == "c" then
        return true
      else
        return not context.in_treesitter_capture("comment") 
          and not context.in_syntax_group("Comment")
      end
    end,
    
    preselect = cmp.PreselectMode.Item,
    
    snippet = {
      expand = function(args)
        if luasnip_ok then
          luasnip.lsp_expand(args.body)
        else
          vim.fn["vsnip#anonymous"](args.body) -- Fallback
        end
      end,
    },
    
    window = M.options.window,
    
    completion = M.options.completion,
    
    confirmation = M.options.confirmation,
    
    performance = M.options.performance,
    
    mapping = cmp.mapping.preset.insert({
      -- Scrolling in completion menu
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      
      -- Manual completion trigger
      ["<C-Space>"] = cmp.mapping.complete(),
      
      -- Close completion menu
      ["<C-e>"] = cmp.mapping.abort(),
      
      -- Confirm completion
      ["<CR>"] = cmp.mapping({
        i = function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
      }),
      
      -- Super Tab behavior
      ["<Tab>"] = cmp.mapping(tab_complete, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(shift_tab_complete, { "i", "s" }),
      
      -- Navigate completion items
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      
      -- Close and fallback
      ["<C-y>"] = cmp.mapping(
        cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }),
        { "i", "c" }
      ),
    }),
    
    sources = build_sources(),
    
    formatting = {
      fields = { "kind", "abbr", "menu" },
      expandable_indicator = true,
      format = function(entry, vim_item)
        local source_config = M.options.sources[entry.source.name]
        local label = source_config and source_config.label or entry.source.name
        
        -- Set the icon
        if kind_icons[vim_item.kind] then
          vim_item.kind = kind_icons[vim_item.kind] .. " " .. vim_item.kind
        end
        
        -- Set the menu (source label)
        vim_item.menu = label
        
        -- Truncate long completions
        if string.len(vim_item.abbr) > 50 then
          vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. "..."
        end
        
        return vim_item
      end,
    },
    
    sorting = {
      priority_weight = 2,
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
    
    experimental = {
      ghost_text = M.options.ghost_text and {
        hl_group = "CmpGhostText",
      } or false,
    },
  })

  -- Command-line completion
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" }
    }
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" }
    }, {
      { name = "cmdline" }
    })
  })

  -- Autopairs integration
  if M.options.autopairs then
    local ok, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
    if ok then
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end

  -- Copilot integration
  if M.options.copilot then
    local ok, copilot_cmp = pcall(require, "copilot_cmp")
    if ok then 
      copilot_cmp.setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end
  end
  
  -- Setup additional integrations
  M.setup_integrations()
end

-- Additional integrations setup
function M.setup_integrations()
  -- DAP completion
  local dap_ok, cmp_dap = pcall(require, "cmp_dap")
  if dap_ok then
    require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
      sources = {
        { name = "dap" },
      },
    })
  end
  
  -- Git completion
  local git_ok, cmp_git = pcall(require, "cmp_git")
  if git_ok then
    cmp_git.setup()
    require("cmp").setup.filetype("gitcommit", {
      sources = require("cmp").config.sources({
        { name = "git" },
      }, {
        { name = "buffer" },
      })
    })
  end
end

-- Utility functions
function M.toggle()
  M.options.enable = not M.options.enable
  if M.options.enable then
    require("cmp").setup.buffer({ enabled = true })
    vim.notify("Completion enabled", vim.log.levels.INFO)
  else
    require("cmp").setup.buffer({ enabled = false })
    vim.notify("Completion disabled", vim.log.levels.INFO)
  end
end

function M.toggle_copilot()
  M.options.copilot = not M.options.copilot
  vim.notify("Copilot " .. (M.options.copilot and "enabled" or "disabled"), vim.log.levels.INFO)
  M.setup() -- Re-setup to apply changes
end

function M.toggle_ghost_text()
  M.options.ghost_text = not M.options.ghost_text
  local cmp = require("cmp")
  cmp.setup({
    experimental = {
      ghost_text = M.options.ghost_text and {
        hl_group = "CmpGhostText",
      } or false,
    },
  })
  vim.notify("Ghost text " .. (M.options.ghost_text and "enabled" or "disabled"), vim.log.levels.INFO)
end

return M