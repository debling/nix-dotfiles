{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./emacs.nix
  ];

  home = {
    packages = with pkgs; [
      libnotify
      zathura
      kicad
      jellyfin-media-player
      hledger-web
    ];
  };

  programs = {
    rbw = lib.mkIf pkgs.stdenv.isLinux {
      settings.pinentry = lib.mkForce pkgs.pinentry-gnome3;
    };
    wezterm.enable = true;
  };

  services.kdeconnect.enable = true;
}
