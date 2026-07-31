{
  pkgs,
  lib,
  ...
}:

{

  imports = [ ];

  home = {
    packages = with pkgs; [
      emacsclient-commands
      # used by doc-view-mode to render pdfs
      mupdf
      # xpdf
      ghostscript
      # used by org-excalidraw to generate svg images from drawings

      # build failling on darwin
      # excalidraw_export

      plantuml-c4
    ];

    shellAliases = {
      e = "emacsclient -nw";
    };
  };

  programs = {
    # The true OS
    emacs = {
      enable = true;
      package = lib.mkDefault pkgs.emacs31-pgtk;
      extraPackages =
        epkgs: with epkgs; [
          clojure-ts-mode
          doom-themes
          eat
          evil
          evil-collection
          hl-todo
          magit
          mu4e
          nix-ts-mode
          org-alert
          org-cliplink
          org-roam
          terraform-mode
          tramp-rpc
          treesit-grammars.with-all-grammars
          zig-ts-mode
          agent-shell
        ];
    };
  };

  xdg.configFile.emacs = {
    source = ../../config/emacs;
    recursive = true;
  };

  services = {
    emacs.enable = true;
  };
}
