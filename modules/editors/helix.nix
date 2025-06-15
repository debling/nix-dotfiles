{ lib, pkgs, ... }:
{
  programs.helix = {
    enable = true;
    extraPackages = [ pkgs.nodePackages.prettier ];
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
          e = ":pipe-to /home/debling/Workspace/probe/replink/run.sh send -l python -t tmux:p=right";
          l = ":sh echo -n '(load-file \"%{buffer_name}\")' | /home/debling/Workspace/probe/replink/run.sh send -l python -t tmux:p=right";
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
      language = [
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
