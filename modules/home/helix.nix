{ lib, pkgs, ... }:
{
  xdg.configFile."codebook/codebook.toml".text = /* toml */ ''
    # List of dictionaries to use for spell checking
    # Default: ["en_us"]
    # Available dictionaries:
    #  - English: "en_us", "en_gb"
    #  - German: "de", "de_at", "de_ch"
    #  - Dutch: "nl_nl"
    #  - Spanish: "es"
    #  - French: "fr"
    #  - Italian: "it"
    #  - Portuguese (Brazil): "pt_br"
    #  - Russian: "ru"
    #  - Swedish: "sv"
    dictionaries = ["en_us", "pt_br"]
  '';

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
        biome = { command = "biome"; args = [ "lsp-proxy" ]; };
        # efm-prettier-md = {
        #   command = lib.getExe pkgs.;
        #   args = ["serve"];  
        # };
        astro-ls = {
          command = lib.getExe pkgs.astro-language-server;
          args = [ "--stdio" ];
          config.typescript.tsdk = "./node_modules/typescript/lib/";
        };
        angular-ls = {
          command = "ngsever";
          args = [
            "--stdio"
          ];
          file-types = [ "ts" "typescript" "html" ];
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
          language-servers = [ "asm-lsp" ];
          grammar = "asm";
          file-types = [ "fasm" ];
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
          name = "typescript";
          language-servers = [ "angular" { name = "typescript-language-server"; except-features = [ "format" ]; } "biome" ];
        }
        {
          name = "tsx";
          language-servers = [{ name = "typescript-language-server"; except-features = [ "format" ]; } "biome"];
        }
        {
          name = "java";
          language-servers = [ "codebook" "jdtls" ];
        }
        {
          name = "javascript";
          language-servers = [ "angular" { name = "typescript-language-server"; except-features = [ "format" ]; } "vscode-eslint-language-server" "biome" ];
        }
        {
          name = "jsx";
          language-servers = [{ name = "typescript-language-server"; except-features = [ "format" ]; } "biome"];
        }
        {
          name = "html";
          language-servers = [ "angular" { name = "typescript-language-server"; except-features = [ "format" ]; } "vscode-eslint-language-server" "biome" ];
        }
        {
          name = "json";
          language-servers = [{ name = "vscode-json-language-server"; except-features = [ "format" ]; } "biome"];
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
