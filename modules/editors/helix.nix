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
    };
    languages = {
      language-server = {
        codebook = {
          command = lib.getExe pkgs.codebook;
          args = ["serve"];  
        };
        # efm-prettier-md = {
        #   command = lib.getExe pkgs.;
        #   args = ["serve"];  
        # };
        astro-ls = {
          command = lib.getExe pkgs.astro-language-server;
          args = ["--stdio"];  
          config.typescript.tsdk = "./node_modules/typescript/lib/";
        };
      };
      language = [
        {
          name = "astro";
          language-servers = ["astro-ls" "tailwindcss-ls"];
          formatter = {
            command = "prettier";
            args = ["--plugin" "prettier-plugin-astro" "--parser" "astro"];
          };
          auto-format = true;
        }
        {
          name = "markdown";
          language-servers = ["codebook" "marksman"];
        }
      ];
    };
  };
}
