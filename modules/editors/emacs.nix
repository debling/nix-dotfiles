{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      emacsclient-commands
      # used by doc-view-mode to render pdfs
      mupdf
      xpdf
      ghostscript
      # used by org-excalidraw to generate svg images from drawings

      # build failling on darwin
      # excalidraw_export 

      plantuml-c4
    ];

    shellAliases = {
      e = "emacs -nw";
    };
  };

  programs = {
    # The true OS
    emacs = {
      enable = true;
      package =
        let
          finalPkg = pkgs.emacs30-pgtk.overrideAttrs (old: {
            patches =
              (old.patches or [ ])
              ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
                # Fix OS window role (needed for window managers like yabai)
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-28/fix-window-role.patch";
                  sha256 = "0c41rgpi19vr9ai740g09lka3nkjk48ppqyqdnncjrkfgvm2710z";
                })
                # Enable rounded window with no decoration
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-30/round-undecorated-frame.patch";
                  sha256 = "0x187xvjakm2730d1wcqbz2sny07238mabh5d97fah4qal7zhlbl";
                })
                # Make Emacs aware of OS-level light/dark mode
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-30/system-appearance.patch";
                  sha256 = "1dkx8xc3v2zgnh6fpx29cf6kc5h18f9misxsdvwvy980cj0cxcwy";
                })
              ];
            NIX_CFLAGS_COMPILE = "${old.NIX_CFLAGS_COMPILE or ""} -O3 -march=native";

          });
          #  finalPkg = emacsPkg.override {
          #    withImageMagick = true;
          #    # withXwidgets = true;
          #  };
        in
        (pkgs.emacsPackagesFor finalPkg).emacsWithPackages (epkgs: with epkgs; [
          nix-mode
          vterm
          treesit-grammars.with-all-grammars
          mu4e
        ]);
    };

    mbsync.enable = true;
    mu.enable = true;
    msmtp.enable = true;
    neomutt = {
      enable = true;
      sidebar.enable = true;
      vimKeys = true;
      sort = "reverse-date";
    };
    notmuch.enable = true;
  };


  xdg.configFile.emacs = {
    source = ../../config/emacs;
    recursive = true;
  };


  accounts.email.accounts = {
    personal =
      let
        addr = "d.ebling8@gmail.com";
      in
      {
        primary = true;
        realName = "Denilson S. Ebling";
        address = addr;
        userName = addr;
        flavor = "gmail.com";
        passwordCommand = "${lib.getExe pkgs.rbw} get mbsync-gmail";

        gpg = {
          key = "CCBC8AA1AF062142";
          signByDefault = true;
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
          patterns = [ "*" "![Gmail]/All Mail" "![Gmail]/Important" ];
        };
        mu.enable = true;
        msmtp.enable = true;
        neomutt = {
          enable = true;
          mailboxName = "personal";
        };
        notmuch = {
          enable = true;
          neomutt.enable = true;
        };
      };

    zeit =
      let
        addr = "denilson@zeit.com.br";
      in
      {
        realName = "Denilson dos Santos Ebling";
        address = addr;
        userName = addr;
        passwordCommand = "${lib.getExe pkgs.rbw} get 'email zeit' | tr --delete '\\n'";
        msmtp.enable = true;
        imap = {
          host = "imap.kinghost.net";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "smtp.kinghost.net";
          port = 465;
          tls.enable = true;
        };

        mbsync = {
          enable = true;
          create = "both";
          expunge = "both";
        };
        mu.enable = true;
        neomutt = {
          enable = true;
          mailboxName = "zeit";
        };
        notmuch = {
          enable = true;
          neomutt.enable = true;
        };
      };
  };
}
