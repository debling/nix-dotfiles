{ pkgs, lib, ... }:

{
  home = {
    packages = with pkgs; [
      emacsclient-commands
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
          emacsPkg = if pkgs.stdenv.isDarwin then pkgs.emacs-macport else pkgs.emacs30-pgtk;
        in
          (pkgs.emacsPackagesFor emacsPkg).emacsWithPackages (epkgs: with epkgs; [
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
  };
  

  xdg.configFile.emacs = {
    source = ../../config/emacs;
    recursive = true;
  };
  

  accounts.email.accounts = {
    personal = {
      primary = true;
      realName = "Denilson S. Ebling";
      address = "d.ebling8@gmail.com";
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
      };
      mu.enable = true;
      msmtp.enable = true;
      neomutt.enable = true;
      notmuch.neomutt.enable = true;
    };

    zeit = let
      addr = "denilson@zeit.com.br";
    in {
      realName = "Denilson dos Santos Ebling";
      address = addr;
      userName = addr;
      passwordCommand = "${lib.getExe pkgs.rbw} get 'email zeit'";

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
      neomutt.enable = true;
      notmuch.neomutt.enable = true;
    };
   };
}
