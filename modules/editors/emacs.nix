{ config, pkgs, lib, ... }:

{
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
      e = "emacs -nw";
    };
  };

  programs = {
    # The true OS
    emacs = {
      enable = true;
      package =
        let
          emacsPkg = pkgs.emacs30-pgtk.overrideAttrs (old: {
            patches =
              (old.patches or [ ])
              ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
                # Fix OS window role (needed for window managers like yabai)
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-28/fix-window-role.patch";
                  sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
                })
                # Enable rounded window with no decoration
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-30/round-undecorated-frame.patch";
                  sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
                })
                # Make Emacs aware of OS-level light/dark mode
                (pkgs.fetchpatch {
                  url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/3e95d573d5f13aba7808193b66312b38a7c66851/patches/emacs-30/system-appearance.patch";
                  sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
                })
              ];

          });
        in
        (pkgs.emacsPackagesFor pkgs.emacs30-pgtk).emacsWithPackages (epkgs: with epkgs; [
          nix-mode
          vterm
          treesit-grammars.with-all-grammars
          mu4e
        ]);
    };

    mbsync.enable = true;
    mu.enable = true;
    msmtp.enable = true;
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
      };
  };

  services.git-sync = {
    enable = true;
    repositories = {
      orgfiles = {
        path = "${config.home.homeDirectory}/Workspace/debling/orgfiles";
        uri = "git@github.com:debling/orgfiles.git";
        interval = 600;
      };
    };
  };
}
