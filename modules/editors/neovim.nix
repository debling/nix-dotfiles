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
      nodePackages.pyright
      nodePackages.typescript-language-server
      # shellcheck
      terraform-ls
    ];
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        dracula-vim

        vim-multiple-cursors
        commentary

        telescope-nvim
        telescope-fzf-native-nvim

        plantuml-syntax

        nvim-treesitter-refactor
        (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))

        nvim-lspconfig
      ];

      extraConfig = ''
        lua require "init_config"
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