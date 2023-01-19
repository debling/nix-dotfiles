{ config, options, lib, pkgs, ... }:

let
  cfg = config.modules.editors.neovim;
  jdtls = pkgs.jdt-language-server.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [ Cocoa ]);
  });
in
{
  options.modules.editors.neovim = {
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
        jdtls # java language server
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
        
        kotlin-language-server

        ### nix
        nil # language server
        statix #  static analysis
      ];
      sessionVariables = {
        EDITOR = "nvim";
        LOMBOK_JAR_PATH = "${pkgs.lombok}/share/java/lombok.jar";
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
