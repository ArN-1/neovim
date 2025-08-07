-- lua/ui.lua
-- Remove the duplicate luasnip loader (already in cmp.lua)
-- require("luasnip.loaders.from_vscode").lazy_load()

-- Setup nvim-tree with proper configuration
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

-- Setup dashboard
require("dashboard").setup({
  theme = "doom",
  config = {
    header = {
      "==========================",
      " NEOVIM",
      "==========================",
    },
    center = {
      { icon = "  ", desc = "File Tree", action = "NvimTreeToggle" },
      { icon = "  ", desc = "Find File", action = "Telescope find_files" },
      { icon = "  ", desc = "Themes", action = "Telescope colorscheme" },
    },
  },
})

-- Setup telescope
require("telescope").setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/" },
  },
})

-- Load telescope extensions (only FZF since treesitter extension doesn't exist)
pcall(require('telescope').load_extension, 'fzf')

-- Setup which-key
require("which-key").setup({
  preset = "modern",
})