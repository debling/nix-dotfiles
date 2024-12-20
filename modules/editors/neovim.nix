{ config, lib, pkgs, ... }:

let
  cfg = config.debling.editors.neovim;
in
{
  options.debling.editors.neovim = {
    enable = lib.mkEnableOption "Enable neovim and its configuration";
  };

  config =
    let
      setups = {
        rust = {
          systemPkgs = with pkgs; [ rust-analyzer cargo rustc clippy ];
          plugins = [ ];
        };

        clojure = {
          systemPkgs = with pkgs; [ clojure-lsp clj-kondo ];
          plugins = with pkgs.vimPlugins; [ conjure cmp-conjure ];
        };

        java = {
          systemPkgs = with pkgs; [ pmd checkstyle ];
          plugins = [ pkgs.vimPlugins.nvim-jdtls ];
        };

        python = {
          systemPkgs = with pkgs; [
            pyright
            ruff-lsp
            ruff
            python311Packages.black
            python311Packages.isort
          ];
          plugins = with pkgs.vimPlugins; [
            otter-nvim ## quarto dependency
            quarto-nvim
          ];
        };

        sql = {
          systemPkgs = with pkgs; [ sqlfluff ];
          plugins = with pkgs.vimPlugins; [
            vim-dadbod
            vim-dadbod-ui
            vim-dadbod-completion
          ];
        };
      };
    in
    lib.mkIf cfg.enable {
      home = {
        sessionVariables = {
          MANPAGER = "nvim +Man!";
        };

        packages = with pkgs; [
          zigpkgs.master
          zls
          checkmake
          clang-tools_18 # C/C++
          bear # wrap make to generate compile_commands.json

          # arduino-language-server
          arduino-cli

          # language servers
          # haskell-language-server
          gopls # go
          nodePackages.bash-language-server
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.typescript-language-server
          angular-language-server
          nodePackages.yaml-language-server
          nodePackages.vscode-langservers-extracted
          shellcheck
          terraform-ls

          ### Lua
          sumneko-lua-language-server
          stylua

          ltex-ls

          ### Kotlin
          kotlin-language-server

          ### nix
          nixd # language server
          statix #  static analysis
          nixfmt-rfc-style

          nodePackages.eslint_d
          nodePackages.prettier

          nodePackages."@tailwindcss/language-server"

          hurl

          ### Dockerfile
          hadolint

          # ### R
          # rPackages.languageserver

          ### Web
          emmet-ls
        ] ++ (lib.concatMap (s: s.systemPkgs) (lib.attrValues setups));

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
          hurl-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "hurl-nvim";

            dependencies = with pkgs.vimPlugins; [ nui-nvim plenary-nvim nvim-treesitter ];

            src = pkgs.fetchFromGitHub {
              owner = "jellydn";
              repo = "hurl.nvim";
              rev = "839784128048251ea9169264b72eaee171fbb1bd";
              hash = "sha256-GSww1LYGw1m+OQB90fTtFgxNjUMnEMlIF3AD7LXVDlg=";
            };
          };

          freeze-code-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "freeze-code-nvim";

            buildInputs = [ pkgs.charm-freeze ];

            src = pkgs.fetchFromGitHub {
              owner = "AlejandroSuero";
              repo = "freeze-code.nvim";
              rev = "b9e54ef8842d831f09298d331e997b574ee0ff78";
              hash = "sha256-EOO8l/V1EPGmxGFXcu+66B7QtaD3lDInUVA56sDahFo=";
            };
          };
        in
        {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          plugins = with pkgs.vimPlugins; [
            base16-nvim

            snacks-nvim

            freeze-code-nvim

            hurl
            hurl-nvim
            render-markdown-nvim

            rainbow-delimiters-nvim

            obsidian-nvim

            arduino-nvim

            vim-multiple-cursors

            ts-comments-nvim

            telescope-nvim
            telescope-fzf-native-nvim
            telescope-ui-select-nvim

            # General plugins

            ## Sintax hilighting
            nvim-treesitter.withAllGrammars
            nvim-treesitter-refactor
            nvim-treesitter-context
            todo-comments-nvim # No setup() call needed

            ## LSP
            nvim-lspconfig
            none-ls-nvim
            fidget-nvim # Show lsp server's status

            nvim-dap
            nvim-dap-ui

            vim-table-mode

            ## Snippets
            nvim-snippets
            friendly-snippets

            ## Completion
            nvim-cmp
            cmp-buffer
            cmp-nvim-lsp
            cmp-path

            lspkind-nvim

            # Language specific
            plantuml-syntax

            kotlin-vim

            ltex_extra-nvim

            ## Git
            gitsigns-nvim
            neogit

            lazydev-nvim

            ## UI
            lualine-nvim
            indent-blankline-nvim

            vim-slime

            vim-sleuth

            SchemaStore-nvim
            oil-nvim

            ## Remember last place on files
            nvim-lastplace

            nvim-web-devicons
          ] ++ (lib.concatMap (s: s.plugins) (lib.attrValues setups));

          extraConfig = "lua require('debling')";
        };

      xdg = {
        configFile = {
          nvim = {
            source = ../../config/nvim;
            recursive = true;
          };
        };

        dataFile = {
          "nvim/jdtls/java-debug" = {
            source =
              "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/";
          };
          "nvim/jdtls/java-test" = {
            source = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/";
          };
        };
      };
    };
}
