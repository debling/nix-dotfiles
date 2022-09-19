{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.editors.neovim;
  jdtls = pkgs.jdt-language-server.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [ Cocoa ]);
  });
in
{
  options.modules.editors.neovim = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable neovim module";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # ccls
      # gopls
      # haskell-language-server
      jdtls # java language server
      # nodePackages.bash-language-server
      # nodePackages.pyright
      nodePackages.typescript-language-server
      # shellcheck
      # terraform-ls
    ];
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        {
          plugin = dracula-vim;
          type = "lua";
          config = builtins.readFile ../../config/nvim/colorscheme.lua;
        }
        vim-multiple-cursors
        commentary
        vim-terraform-completion

        telescope-nvim
        telescope-fzf-native-nvim

        plantuml-syntax

        nvim-treesitter-refactor
        {
          plugin = nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars);
          type = "lua";
          config = builtins.readFile ../../config/nvim/treesitter.lua;
        }
        nvim-lspconfig
      ];

      extraConfig = ''
        """ Basic config
        set number relativenumber
        set autoindent
        set smartindent
        set hlsearch
        set smartcase
        set clipboard+=unnamedplus
        set scrolloff=5
        set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
        let mapleader=" "
        lua require "initconfig"
      '';
    };

    xdg.configFile = {
      nvim = {
        source = ../../config/nvim;
        recursive = true;
      };
    };

  };
}
