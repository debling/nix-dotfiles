{ config
, lib
, pkgs
, neovim-nightly-overlay
, ...
}:

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
            #zls
          ];
        };

        sh = {
          systemPkgs = with pkgs; [
            hadolint
            dockerfile-language-server
            nodePackages.bash-language-server
            shellcheck
            shfmt
          ];
        };

        rust = {
          systemPkgs = with pkgs; [
            rust-analyzer
            cargo
            rustc
            clippy
          ];
        };

        clojure = {
          systemPkgs = with pkgs; [
            clojure-lsp
            clj-kondo
          ];
          plugins = with pkgs.vimPlugins; [ conjure ];
        };

        java = {
          systemPkgs =
            with pkgs;
            let
              jdt = jdt-language-server.overrideAttrs {

                postPatch = ''
                  substituteInPlace bin/jdtls.py \
                    --replace-fail "jdtls_base_path = Path(__file__).parent.parent" "jdtls_base_path = Path(\"$out/share/java/jdtls/\")"
                '';
              };
              jdtls-with-lombok = pkgs.writeShellScriptBin "jdtls" ''
                ${lib.getExe jdt} \
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
          systemPkgs = with pkgs; [
            angular-language-server
            astro-language-server
            biome
            emmet-ls
            html-tidy
            #hurl
            nodePackages."@tailwindcss/language-server"
            nodePackages.typescript-language-server
            nodePackages.vscode-langservers-extracted
            nodePackages.yaml-language-server
            prettier
          ];
          plugins = with pkgs.vimPlugins; [
            hurl
            hurl-nvim
          ];
        };
      };
    in
    lib.mkIf cfg.enable {
      home = {
        packages =
          with pkgs;
          [
            trivy
            go
            gopls # go
            terraform-ls
            ### Lua
            sumneko-lua-language-server
            stylua
            ltex-ls
            texlab
            ### nix
            nixd # language server
            statix # static analysis
            nixfmt-rfc-style
            marksman
          ]
          ++ (lib.concatMap (s: s.systemPkgs) (lib.attrValues setups));

        sessionVariables = {
          EDITOR = "nvim";
        };
      };

      programs.neovim = {
        enable = true;
        package = neovim-nightly-overlay.packages.${pkgs.system}.default;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        plugins =
          with pkgs.vimPlugins;
          [
            harpoon2
            snacks-nvim
            rainbow-delimiters-nvim
            obsidian-nvim
            ts-comments-nvim
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-ui-select-nvim

            # General plugins

            ## Sintax hilighting
            nvim-treesitter.withAllGrammars
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

            ## UI
            vim-slime

            SchemaStore-nvim
          ]
          ++ (lib.concatMap (s: s.plugins or [ ]) (lib.attrValues setups));

      };

      xdg = {
        configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Workspace/debling/nix-dotfiles/modules/home/neovim/config";

        dataFile = {
          "nvim/jdtls/java-debug" = {
            source = "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/";
          };
          "nvim/jdtls/java-test" = {
            source = "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/";
          };
        };
      };
    };
}
