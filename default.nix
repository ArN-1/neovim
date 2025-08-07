{ pkgs, lib, ... }:

let
  plugins = import ./plugins.nix { inherit pkgs; };
  luaConfig = builtins.readFile ./lua/init.lua;
in {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    withPython3 = true;

    plugins = plugins;

    extraConfig = ''
      set number
      set relativenumber
      set cursorline
      set scrolloff=5
      set tabstop=4 shiftwidth=4 expandtab
      filetype plugin indent on
    '';

    extraLuaConfig = luaConfig;
  };

  # Copy folder lua/ to ~/.config/nvim/lua/
  home.file.".config/nvim/lua".source = ./lua;

  home.packages = with pkgs; [
    # Neovim-specific tools only (others are in packages.nix)
    lazygit    # Git TUI for LazyGit plugin
    nodejs     # Required for some LSP servers
    unzip      # Required for some plugins
    
    # Additional formatters not in packages.nix
    stylua          # Lua formatter
    nodePackages.prettier  # JS/TS/JSON formatter
  ];
}