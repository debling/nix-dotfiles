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
        nodePackages.vscode-langservers-extracted
        shellcheck
        sumneko-lua-language-server
        terraform-ls
        texlab
        stylua

        ltex-ls

        ### SQL

        ### Kotlin
        kotlin-language-server

        ### nix
        nil # language server
        statix #  static analysis

        nodePackages.eslint_d
        nodePackages.prettier_d_slim

        ### python
        ruff
        python311Packages.black
        python311Packages.isort

        nodePackages."@tailwindcss/language-server"

        hurl
      ];
      sessionVariables = {
        EDITOR = "nvim";
      };
    };
    programs.neovim =
      let
        iron-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "iron-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "Vigemus";
            repo = "iron.nvim";
            rev = "792dd11752c4699ea52c737b5e932d6f21b25834";
            hash = "sha256-aNDZSAjEwTx72DFjxHG2RYbfGNUQe86SFpOAnlZItm0=";
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

          ltex_extra-nvim

          neogit

          neodev-nvim

          ## UI
          lualine-nvim
          which-key-nvim

          iron-nvim

          rest-nvim

          vim-test
          hurl

          SchemaStore-nvim
          oil-nvim
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
