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
      kicad
      jellyfin-media-player
    ];
  };

  programs = {
    rbw = lib.mkIf pkgs.stdenv.isLinux {
      settings.pinentry = lib.mkForce pkgs.pinentry-gnome3;
    };
  };

  services.kdeconnect.enable = true;
}
