{ lib, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    extraPackages = [ pkgs.nodePackages.prettier pkgs.asm-lsp ];
    themes = {
      transparent_bg = {
        inherits = "gruvbox_dark_hard";
        "ui.background" = "";
      };
    };
    settings = {
      theme = "transparent_bg";
      editor = {
        line-number = "relative";
      };
      keys.normal.space = {
        e = {
          e = ":pipe-to tmux-pipe";
          l = ":sh echo -n '(load-file \"%{buffer_name}\")' | tmux-pipe";
        };
      };
    };
    languages = {
      language-server = {
        codebook = {
          command = lib.getExe pkgs.codebook;
          args = [ "serve" ];
        };
        # efm-prettier-md = {
        #   command = lib.getExe pkgs.;
        #   args = ["serve"];  
        # };
        astro-ls = {
          command = lib.getExe pkgs.astro-language-server;
          args = [ "--stdio" ];
          config.typescript.tsdk = "./node_modules/typescript/lib/";
        };
      };
      grammar = [
        {
          name = "asm";
          source = { git = "https://github.com/RubixDev/tree-sitter-asm"; rev = "04962e15f6b464cf1d75eada59506dc25090e186"; };
        }
              ];
      language = [
        {
          name = "fasm";
          scope = "source.fasm";
          comment-token = ";";
          indent = { tab-width = 4; unit = "    "; };
          language-servers = [ "asm-lsp"];
          grammar = "asm";
          file-types = ["fasm"];
        }
        {
          name = "astro";
          language-servers = [ "astro-ls" "tailwindcss-ls" ];
          formatter = {
            command = "prettier";
            args = [ "--plugin" "prettier-plugin-astro" "--parser" "astro" ];
          };
          auto-format = true;
        }
        {
          name = "markdown";
          language-servers = [ "codebook" "marksman" ];
        }
        {
          name = "clojure";
          indent = { tab-width = 2; unit = "  "; };
          formatter = { command = "cljfmt"; args = [ "fix" "-" ]; };
          auto-format = true;
        }
      ];
    };
  };
}
