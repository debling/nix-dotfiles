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
      default = false;
      description = "Enable neovim module";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # language servers
        /* haskell-language-server */
        ccls
        gopls
        jdtls # java language server
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.pyright
        nodePackages.typescript-language-server
        nodePackages.yaml-language-server
        rnix-lsp
        shellcheck
        sumneko-lua-language-server
        terraform-ls
        texlab
      ];
      sessionVariables = {
        EDITOR = "nvim";
        LOMBOK_JAR_PATH = "${pkgs.lombok}/share/java/lombok.jar";
      };
    };
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
        telescope-ui-select-nvim

        # General plugins
        ## Sintax hilighting
        nvim-treesitter.withAllGrammars
        nvim-treesitter-refactor
        nvim-treesitter-context

        nvim-tree-lua

        nvim-lspconfig
        
        null-ls-nvim

        vim-table-mode

        editorconfig-nvim

        ## Snippets
        luasnip

        ## Completion
        nvim-cmp
        cmp-buffer
        cmp-nvim-lsp
        cmp_luasnip
        cmp-path

        lspkind-nvim

        # Language specific
        plantuml-syntax

        orgmode

        markdown-preview-nvim

        neogit

        cmp-copilot
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
