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
        arduino-language-server
        arduino-cli
        # language servers
        # haskell-language-server
        gopls
        ccls
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

        ### Dockerfile
        hadolint
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
            rev = "9017061849e543d8e94b79d2a94b95e856ab6a10";
            hash = "sha256-XJXi3i7wpBWDd5sny90Gw6ucOlnn1m8sYSVcUh/3Ufk=";
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
          nvim-ts-context-commentstring

          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim

          # General plugins
          vim-sleuth

          ## Sintax hilighting
          nvim-treesitter.withAllGrammars
          nvim-treesitter-refactor
          nvim-treesitter-context

          nvim-tree-lua

          ## LSP
          trouble-nvim
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

          ## Git
          gitsigns-nvim
          neogit

          neodev-nvim
          neoconf-nvim

          ## UI
          lualine-nvim
          which-key-nvim
          indent-blankline-nvim

          vim-slime

          rest-nvim

          vim-test
          hurl

          SchemaStore-nvim
          oil-nvim

          nvim-lastplace

          nvim-web-devicons

          vim-dadbod
          vim-dadbod-ui
          vim-dadbod-completion
        ];

        extraConfig = "lua require('init_config')";
      };

    xdg.configFile = {
      nvim = {
        source = ../../config/nvim;
        recursive = true;
      };
    };
  };
}
