{ config, options, lib, pkgs, ... }:

let
  cfg = config.myModules.editors.neovim;
in
{
  options.myModules.editors.neovim = {
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
        # haskell-language-server
        ccls
        gopls
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.pyright
        nodePackages.typescript-language-server
        nodePackages.yaml-language-server
        shellcheck
        sumneko-lua-language-server
        terraform-ls
        texlab
        stylua
        ltex-ls

        ### SQL
        sqls

        ### Kotlin
        kotlin-language-server

        ### nix
        nil # language server
        statix #  static analysis

        nodePackages.eslint_d
        nodePackages.prettier_d_slim
      ];
      sessionVariables = {
        EDITOR = "nvim";
      };
    };
    programs.neovim =
      let
        ltex-extra-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "ltex-extra-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "barreiroleo";
            repo = "ltex_extra.nvim";
            rev = "c5046a6eabfee378f781029323efd941fcc53483";
            hash = "sha256-gTbtjqB6ozoTAkxp0PZUjD/kndxf2eJrXWlkZdj7+OQ=";
          };
        };

        sqls-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "sqls-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "nanotee";
            repo = "sqls.nvim";
            rev = "a0048b7018c99b68456f91b4aa42ce288f0c0774";
            hash = "sha256-tatUEAI8EVXDYQPAAZ5+38YOPWb8Ei9VHCzHp+AyRjc=";
          };
        };

        iron-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "iron-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "Vigemus";
            repo = "iron.nvim";
            rev = "792dd11752c4699ea52c737b5e932d6f21b25834";
            hash = "sha256-tatUEAI8EVXDYQPAAZ5+38YOPWb8Ei9VHCzHp+AyRjc=";
          };
        };
      in
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          gruvbox-nvim

          vim-multiple-cursors
          comment-nvim

          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim

          # General plugins
          vim-sleuth
          indent-blankline-nvim
          vimwiki

          ## Sintax hilighting
          nvim-treesitter.withAllGrammars
          nvim-treesitter-refactor
          nvim-treesitter-context

          nvim-tree-lua

          ## LSP
          nvim-lspconfig
          null-ls-nvim
          fidget-nvim # Show lsp server's status

          sqls-nvim

          vim-table-mode

          editorconfig-nvim

          lsp-colors-nvim

          ## Snippets
          luasnip
          friendly-snippets

          ## Completion
          nvim-cmp
          cmp-buffer
          cmp-copilot
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip

          lspkind-nvim

          # Language specific
          plantuml-syntax

          kotlin-vim

          orgmode

          markdown-preview-nvim

          neogit

          neodev-nvim

          ltex-extra-nvim

          ## UI
          lualine-nvim
          which-key-nvim

          iron-nvim
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
