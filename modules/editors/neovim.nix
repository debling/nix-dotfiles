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
          sonarlint-ls
          checkmake
          clang-tools_18 # C/C++
          bear # wrap make to generate compile_commands.json

          arduino-language-server
          arduino-cli

          # language servers
          # haskell-language-server
          gopls # go
          nodePackages.bash-language-server
          nodePackages.dockerfile-language-server-nodejs
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

          ### Dockerfile
          hadolint

          # ### R
          rPackages.languageserver

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

          freeze-code-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "freeze-code-nvim";

            buildInputs = [ pkgs.charm-freeze ];

            src = pkgs.fetchFromGitHub {
              owner = "AlejandroSuero";
              repo = "freeze-code.nvim";
              rev = "e49fc7f13e49be30621038ce8067c0d821f813a3";
              hash = "sha256-1NGM7bmCQj5ssOgmPGUWtWDtmcrtl59yAAvTEE+P7VE=";
            };
          };

          sonarlint-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "sonarlint-nvim";

            buildInputs = [ pkgs.sonarlint-ls ];

            src = pkgs.fetchFromGitLab {
              owner = "schrieveslaach";
              repo = "sonarlint.nvim";
              rev = "3ccb3e5452b0c075e4fb7dbee436d4e65d34d294";
              hash = "sha256-/hESKG0K/U4iGFe5b1byWcDuFsju8g7fUBL5AYFhavo=";
            };
          };

          solarized-nvim = pkgs.vimUtils.buildVimPlugin {
            name = "solarized-nvim";

            src = pkgs.fetchFromGitHub {
              owner = "maxmx03";
              repo = "solarized.nvim";
              rev = "6875d609077411c88d293cb0520ca4e08b829ded";
              hash = "sha256-Jg9HC3rvxLv4dI/r84TYZpaabkEYh1qHTtusMVaoj+Q=";
            };
          };
        in
        {
          enable = true;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          plugins = with pkgs.vimPlugins; [
            solarized-nvim
            sonarlint-nvim
            bigfile-nvim

            freeze-code-nvim

            hurl
            hurl-nvim

            rainbow-delimiters-nvim

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
