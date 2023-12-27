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
      {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins = with pkgs.vimPlugins; [
          vim-startuptime
          gruvbox-nvim

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
