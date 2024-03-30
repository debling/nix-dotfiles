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
        ruff-lsp
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
        terraform-ls
        texlab

        ### Lua
        sumneko-lua-language-server
        stylua

        ltex-ls

        ### SQL

        ### Kotlin
        kotlin-language-server

        ### nix
        nil # language server
        statix #  static analysis
        nixpkgs-fmt

        nodePackages.eslint_d
        nodePackages.prettier

        ### python
        ruff
        python311Packages.black
        python311Packages.isort

        nodePackages."@tailwindcss/language-server"

        ### SQL
        sqlfluff

        hurl


        ### Java
        pmd
        checkstyle
        # sonar-scanner-cli

        ### Dockerfile
        hadolint

        ### R
        rPackages.languageserver

        ### Web
        emmet-ls
      ];

      sessionVariables = {
        EDITOR = "nvim";
      };
    };

    programs.neovim =
      let
        arduino-nvim = pkgs.vimUtils.buildVimPlugin {
          name = "arduino-nvim";
          src = pkgs.fetchFromGitHub {
            owner = "edKotinsky";
            repo = "Arduino.nvim";
            rev = "38559b12dee24e8680565f669e6abac8d11f705d";
            hash = "sha256-4z8aL+ZyS8yeFdRY4+J+CHK2C0+2bJJeaEF+G840COU=";
          };
        };
        harpoon = pkgs.vimUtils.buildVimPlugin {
          name = "harpoon";
          src = pkgs.fetchFromGitHub {
            owner = "ThePrimeagen";
            repo = "harpoon";
            rev = "a38be6e0dd4c6db66997deab71fc4453ace97f9c";
            hash = "sha256-RjwNUuKQpLkRBX3F9o25Vqvpu3Ah1TCFQ5Dk4jXhsbI=";
          };
        };
      in
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          obsidian-nvim

          nui-nvim

          arduino-nvim
          vim-startuptime
          # gruvbox-nvim
          catppuccin-nvim

          vim-multiple-cursors

          comment-nvim
          nvim-ts-context-commentstring

          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim

          # General plugins

          ## Sintax hilighting
          nvim-treesitter.withAllGrammars
          nvim-treesitter-refactor
          nvim-treesitter-context
          todo-comments-nvim # No setup() call needed
          harpoon

          ## LSP
          nvim-lspconfig
          none-ls-nvim
          fidget-nvim # Show lsp server's status
          lsp-colors-nvim

          nvim-dap
          # nvim-dap-ui

          nvim-jdtls

          vim-table-mode

          editorconfig-nvim

          ## Snippets
          luasnip
          friendly-snippets

          ## Completion
          nvim-cmp
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip

          lspkind-nvim

          copilot-lua
          copilot-cmp

          # Language specific
          plantuml-syntax

          kotlin-vim

          ### Markdown
          # Preview Markdown in real-time, on the browser
          markdown-preview-nvim

          ltex_extra-nvim

          ## Git
          gitsigns-nvim
          neogit

          neodev-nvim

          ## UI
          lualine-nvim
          indent-blankline-nvim

          vim-slime
          vim-sleuth

          hurl

          SchemaStore-nvim
          oil-nvim

          ## Remember last place on files
          nvim-lastplace

          nvim-web-devicons

          # Plugin to interact with SQL databases
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
