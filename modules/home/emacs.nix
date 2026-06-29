{
  config,
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
      package = pkgs.emacs31-pgtk;
      extraPackages =
        epkgs: with epkgs; [
          evil
          evil-collection
          magit
          mu4e
          treesit-grammars.with-all-grammars
          zig-ts-mode
          nix-ts-mode
          terraform-mode
          org-cliplink
          org-roam
          org-alert
          doom-themes
          vterm
          tramp-rpc
          eat
          hl-todo
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
