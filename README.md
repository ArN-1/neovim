# 🛠️ Neovim Configuration for NixOS

This repository contains a modular and reproducible Neovim configuration, written in Lua and integrated declaratively using Nix. It is optimized for development with built-in support for LSP, autocompletion, debugging, formatting, and UI enhancements.

---

## 📁 Directory Structure

```js

modules/user/neovim/
├── default.nix # Neovim and plugin declarations for NixOS
├── plugins.nix # List of Vim plugins via pkgs.vimPlugins
└── lua/ # Modular Lua configuration files
├── init.lua # Main entry point that loads all modules
├── lsp.lua # LSP configurations (e.g. basedpyright)
├── cmp.lua # Autocompletion setup with nvim-cmp and LuaSnip
├── formatter.lua # Code formatting integration
├── dap.lua # Debug Adapter Protocol (DAP) setup
├── autopairs.lua # Autopairing brackets and quotes
├── keymaps.lua # Keybindings and shortcuts
└── ui.lua # UI-related settings (statusline, theme, etc.)

```




## 🚀 Features

- Fully declarative via [NixOS](https://nixos.org) or [Home Manager](https://nix-community.github.io/home-manager/)
- Clean Lua-based modular configuration
- LSP and DAP support for modern development workflows
- Autocompletion using `nvim-cmp` and `LuaSnip`
- Lightweight, fast startup
- Formatter support via `null-ls` or custom tools
- UI customization with lualine, themes, etc.

---

## 🧩 Plugin Stack (via `plugins.nix`)

Make sure the following plugins (and their dependencies) are declared:

- [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp)
- [`LuaSnip`](https://github.com/L3MON4D3/LuaSnip)
- [`friendly-snippets`](https://github.com/rafamadriz/friendly-snippets)
- [`cmp_luasnip`](https://github.com/saadparwaiz1/cmp_luasnip)
- [`nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig)
- [`nvim-dap`](https://github.com/mfussenegger/nvim-dap)
- [`nvim-autopairs`](https://github.com/windwp/nvim-autopairs)
- [`lualine.nvim`](https://github.com/nvim-lualine/lualine.nvim)

## Notes

- The init.lua file loads all Lua modules under lua/ in a clean and structured manner.

- You can easily extend functionality by creating additional modules.

- The configuration assumes a modern Neovim version (≥ 0.9.0).

- Snippet handling and LSP setup are filetype-agnostic and auto-loaded.



