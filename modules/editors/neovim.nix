{ config, lib, pkgs, ... }:

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

  config =
    let
      setups = {
        clojure = {
          systemPkgs = with pkgs; [ clojure-lsp clj-kondo ];
          plugins = with pkgs.vimPlugins; [ conjure cmp-conjure ];
        };

        java = {
          systemPkgs = with pkgs; [ pmd checkstyle ];
          plugins = [ pkgs.vimPlugins.nvim-jdtls ];
        };

        sql = {
          systemPkgs = with pkgs; [
            ruff-lsp
            ruff
            python311Packages.black
            python311Packages.isort
          ];
          plugins = [ ];
        };

        python = {
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
          clang-tools_18 # C/C++
          bear # wrap make to generate compile_commands.json

          arduino-language-server
          arduino-cli

          # language servers
          # haskell-language-server
          gopls # go
          nodePackages.bash-language-server
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.pyright
          nodePackages.typescript-language-server
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
          nil # language server
          statix #  static analysis
          nixpkgs-fmt

          nodePackages.eslint_d
          nodePackages.prettier


          nodePackages."@tailwindcss/language-server"

          hurl


          # sonar-scanner-cli

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
          harpoon = pkgs.vimUtils.buildVimPlugin {
            name = "harpoon";

            dependencies = with pkgs.vimPlugins; [ plenary-nvim ];

            src = pkgs.fetchFromGitHub {
              owner = "ThePrimeagen";
              repo = "harpoon";
              rev = "0378a6c428a0bed6a2781d459d7943843f374bce";
              hash = "sha256-FZQH38E02HuRPIPAog/nWM55FuBxKp8AyrEldFkoLYk=";
            };
          };

          hurl-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "hurl-nvim";

            dependencies = with pkgs.vimPlugins; [ nui-nvim plenary-nvim nvim-treesitter ];

            src = pkgs.fetchFromGitHub {
              owner = "jellydn";
              repo = "hurl.nvim";
              rev = "fccd096f555864d3de1f103622c7020224ba6246";
              hash = "sha256-dvApkpcRBSN5dFJI8Gmqz5kWkvO3O4q++LqC70jGgr4=";
            };
          };
        in
        {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          plugins = with pkgs.vimPlugins; [
            hurl
            hurl-nvim

            rainbow-delimiters-nvim

            gruvbox-nvim

            obsidian-nvim

            arduino-nvim

            vim-multiple-cursors

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

            nvim-dap
            nvim-dap-ui

            vim-table-mode

            editorconfig-nvim

            ## Snippets
            nvim-snippets
            friendly-snippets

            ## Completion
            nvim-cmp
            cmp-buffer
            cmp-nvim-lsp
            cmp-path

            lspkind-nvim

            copilot-lua
            copilot-cmp

            # Language specific
            plantuml-syntax

            kotlin-vim

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

            SchemaStore-nvim
            oil-nvim

            ## Remember last place on files
            nvim-lastplace

            nvim-web-devicons
          ] ++ (lib.concatMap (s: s.plugins) (lib.attrValues setups));

          extraConfig = "lua require('debling.init_config')";
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
