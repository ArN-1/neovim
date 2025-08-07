{ pkgs }:

with pkgs.vimPlugins; [
  # UI
  vim-airline
  { plugin = vim-airline-themes; config = "let g:airline_theme='wombat'"; }
  nvim-tree-lua
  telescope-nvim
  telescope-fzf-native-nvim
  
  # Treesitter
  (nvim-treesitter.withPlugins (p: [
    p.python
    p.lua
    p.dockerfile
    p.yaml
    p.markdown
    p.json
    p.javascript
    p.typescript
    p.bash
    p.nix
    p.vim
    p.vimdoc
  ]))
  nvim-treesitter-textobjects
  
  dashboard-nvim
  which-key-nvim
  
  # Icons
  nvim-web-devicons
  mini-nvim
  plenary-nvim
  nui-nvim

  # Theme
  { plugin = dracula-nvim; config = "colorscheme dracula\nsyntax enable"; }

  # Autocomplete (CMP)
  nvim-cmp
  cmp-nvim-lsp
  cmp-buffer
  cmp-path
  cmp-cmdline
  cmp-nvim-lua
  cmp-nvim-lsp-signature-help
  
  # Snippets - Choose ONE: either LuaSnip OR vsnip
  # Option 1: LuaSnip (recommended)
  luasnip
  friendly-snippets
  cmp_luasnip
  
  # Option 2: vsnip (uncomment these if you prefer vsnip)
  # vim-vsnip
  # cmp-vsnip

  # LSP
  nvim-lspconfig
  lazy-lsp-nvim
  mason-nvim
  mason-lspconfig-nvim

  
  # Formatter & Linter
  conform-nvim
  nvim-lint

  # Git & GitHub
  vim-fugitive
  gitsigns-nvim
  octo-nvim
  lazygit-nvim

  # Debugger (DAP)
  nvim-dap
  nvim-dap-ui
  nvim-dap-python

  # Autopairs
  {
    plugin = nvim-autopairs;
    config = ''
      lua << EOF
      require("nvim-autopairs").setup({})
      EOF
    '';
  }
]