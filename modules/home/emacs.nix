{ config, pkgs, lib, ... }:

{

  imports = [ ];

  xdg.configFile."neomutt/mailcap".text = ''
    *; ${pkgs.xdg-utils}/bin/xdg-open %s &
  '';

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
        (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (epkgs: with epkgs; [
          mu4e
          treesit-grammars.with-all-grammars
        ]);
    };

    mbsync.enable = true;
    mu.enable = true;
    msmtp.enable = true;
    notmuch.enable = true;
    neomutt = {
      enable = true;
      sidebar.enable = true;
      vimKeys = true;
      sort = "reverse-date";
      unmailboxes = true;
      extraConfig = /* muttrc */ ''
        set reverse_name
        set fast_reply
        set fcc_attach
        set forward_quote
        set sidebar_format='%D%?F? [%F]?%* %?N?%N/? %?S?%S?'
        set mail_check_stats
        # set mailcap_path=${config.xdg.configHome}/neomutt/mailcap
        set mark_old = no
        # set pgp_default_key = ""
        auto_view text/html

        # Default index colors:
        color index yellow default '.*'
        color index_author red default '.*'
        color index_number blue default
        color index_subject cyan default '.*'

        # New mail is boldened:
        color index brightyellow black "~N"
        color index_author brightred black "~N"
        color index_subject brightcyan black "~N"

        # Tagged mail is highlighted:
        color index brightyellow blue "~T"
        color index_author brightred blue "~T"
        color index_subject brightcyan blue "~T"

        # Flagged mail is highlighted:
        color index brightgreen default "~F"
        color index_subject brightgreen default "~F"
        color index_author brightgreen default "~F"

        # Other colors and aesthetic settings:
        mono bold bold
        mono underline underline
        mono indicator reverse
        mono error bold
        color normal default default
        color indicator brightblack white
        color sidebar_highlight red default
        color sidebar_divider brightblack black
        color sidebar_flagged red black
        color sidebar_new green black
        color error red default
        color tilde black default
        color message cyan default
        color markers red white
        color attachment white default
        color search brightmagenta default
        color status brightyellow black
        color hdrdefault brightgreen default
        color quoted green default
        color quoted1 blue default
        color quoted2 cyan default
        color quoted3 yellow default
        color quoted4 red default
        color quoted5 brightred default
        color signature brightgreen default
        color bold black default
        color underline black default

        # Regex highlighting:
        color header brightmagenta default "^From"
        color header brightcyan default "^Subject"
        color header brightwhite default "^(CC|BCC)"
        color header blue default ".*"
        color body brightred default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
        color body brightblue default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
        color body green default "\`[^\`]*\`" # Green text between ` and `
        color body brightblue default "^# \.*" # Headings as bold blue
        color body brightcyan default "^## \.*" # Subheadings as bold cyan
        color body brightgreen default "^### \.*" # Subsubheadings as bold green
        color body yellow default "^(\t| )*(-|\\*) \.*" # List items as yellow
        color body brightcyan default "[;:][-o][)/(|]" # emoticons
        color body brightcyan default "[;:][)(|]" # emoticons
        color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
        color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
        color body red default "(BAD signature)"
        color body cyan default "(Good signature)"
        color body brightblack default "^gpg: Good signature .*"
        color body brightyellow default "^gpg: "
        color body brightyellow red "^gpg: BAD signature from.*"
        mono body bold "^gpg: Good signature"
        mono body bold "^gpg: BAD signature from.*"
        color body red default "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"
      '';

      binds = [
        {
          map = [ "index" ];
          key = "l";
          action = "display-message";
        }
        {
          map = [ "pager" ];
          key = "l";
          action = "view-attachments";
        }
        {
          map = [ "attach" ];
          key = "l";
          action = "view-mailcap";
        }
        {
          map = [
            "pager"
            "attach"
          ];
          key = "h";
          action = "exit";
        }
        {
          map = [ "index" ];
          key = "h";
          action = "noop";
        }
        {
          map = [ "index" ];
          key = "L";
          action = "limit";
        }
        {
          map = [ "index" ];
          key = "N";
          action = "toggle-new";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\Ck";
          action = "sidebar-prev";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\Cj";
          action = "sidebar-next";
        }
        {
          map = [
            "index"
            "pager"
          ];
          key = "\\Co";
          action = "sidebar-open";
        }
      ];

      macros = [
        {
          map = [ "index" ];
          key = "o";
          action = "<shell-escape>notmuch new<enter>";
        }
        {
          map = [ "index" ];
          key = "\\Cf";
          action = "<vfolder-from-query>";
        }
      ];

    };
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
          extraConfig = ''
            mailboxes `find ~/Maildir/personal -type d -name cur -exec dirname {} \; | sort | awk '{ printf "\"%s\" ", $0 }'`
          '';
        };
        notmuch = {
          enable = true;
          neomutt.enable = true;
        };

        folders = {
          sent = "[Gmail]/Sent Mail";
          drafts = "[Gmail]/Drafts";
          trash = "[Gmail]/Trash";
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
          extraConfig = ''
            mailboxes `find ~/Maildir/zeit -type d -name cur -exec dirname {} \; | sort | awk '{ printf "\"%s\" ", $0 }'`
          '';
        };
        notmuch = {
          enable = true;
          neomutt.enable = true;
        };
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
