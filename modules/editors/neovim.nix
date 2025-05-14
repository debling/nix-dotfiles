{ config, lib, pkgs, colorscheme, ... }:

let
  cfg = config.debling.editors.neovim;
in
{
  options.debling.editors.neovim = {
    enable = lib.mkEnableOption "Enable neovim and its configuration";
    package = lib.mkPackageOption pkgs "neovim" { };
  };

  config =
    let
      setups = {
        c = {
          systemPkgs = with pkgs; [
            checkmake
            clang-tools_18 # C/C++
            bear # wrap make to generate compile_commands.json
          ];
        };

        zig = {
          systemPkgs = with pkgs; [
            zigpkgs.master
            # zls
          ];
        };

        sh = {
          systemPkgs = with pkgs; [
            hadolint
            nodePackages.dockerfile-language-server-nodejs
            nodePackages.bash-language-server
            shellcheck
            shfmt
          ];
        };

        rust = {
          systemPkgs = with pkgs; [ rust-analyzer cargo rustc clippy ];
        };

        clojure = {
          systemPkgs = with pkgs; [ clojure-lsp clj-kondo ];
          plugins = with pkgs.vimPlugins; [ conjure ];
        };

        java = {
          systemPkgs = with pkgs;
            let
              jdtls-with-lombok = pkgs.writeShellScriptBin "jdtls-with-lombok" ''
                ${lib.getExe jdt-language-server} \
                  --jvm-arg=-javaagent:${lombok}/share/java/lombok.jar \
                  --jvm-arg=-Dlog.level=ALL \
                  $@
              '';
            in
            [
              pmd
              checkstyle
              jdtls-with-lombok
            ];
          plugins = [ pkgs.vimPlugins.nvim-jdtls ];
        };

        python = {
          systemPkgs = with pkgs; [
            pyright
            ruff
            python312Packages.black
            python312Packages.isort
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

        web = {
          systemPkgs = with pkgs;
            [
              nodePackages.typescript-language-server
              angular-language-server
              nodePackages.yaml-language-server
              nodePackages.vscode-langservers-extracted
              nodePackages.eslint_d
              nodePackages.prettier
              nodePackages."@tailwindcss/language-server"
              emmet-ls
              hurl
              html-tidy
            ];
          plugins = with pkgs.vimPlugins;
            let
              hurl-nvim = pkgs.vimUtils.buildVimPlugin {
                name = "hurl-nvim";
                doCheck = false;

                dependencies = [ nui-nvim ];

                src = pkgs.fetchFromGitHub {
                  owner = "jellydn";
                  repo = "hurl.nvim";
                  rev = "v2.1.0";
                  hash = "sha256-h3uANPgLOKV/js6YTtHctjwgMg01Z71kuAecCKbs5Gs=";
                };
              };
            in
            [
              hurl
              hurl-nvim
              render-markdown-nvim
            ];
        };
      };
    in
    lib.mkIf cfg.enable {
      home = {
        packages = with pkgs; [
          gopls # go
          terraform-ls
          ### Lua
          sumneko-lua-language-server
          stylua
          ltex-ls
          texlab
          ### nix
          nixd # language server
          statix #  static analysis
          nixfmt-rfc-style
        ] ++ (lib.concatMap (s: s.systemPkgs) (lib.attrValues setups));

        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      programs.neovim =
        let
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
          # package = cfg.package;
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          plugins = with pkgs.vimPlugins; [
            blink-cmp
            friendly-snippets # used by blink.cmp

            harpoon2

            snacks-nvim

            freeze-code-nvim

            rainbow-delimiters-nvim

            obsidian-nvim

            vim-multiple-cursors

            ts-comments-nvim

            telescope-nvim
            telescope-fzf-native-nvim
            telescope-ui-select-nvim

            # General plugins

            ## Sintax hilighting
            (nvim-treesitter.withPlugins (_:
              let
                isNotOcamlLex = x: !lib.hasPrefix "ocamllex" x.name;
              in
              lib.filter isNotOcamlLex nvim-treesitter.allGrammars))
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

            # Language specific
            ltex_extra-nvim

            ## Git
            gitsigns-nvim
            neogit

            lazydev-nvim

            ## UI
            vim-slime

            vim-sleuth

            SchemaStore-nvim

            ## Remember last place on files
            nvim-lastplace

            nvim-web-devicons
          ] ++ (lib.concatMap (s: s.plugins or [ ]) (lib.attrValues setups));

          extraConfig = /* vim */ ''
            lua require('debling')
          '';
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
