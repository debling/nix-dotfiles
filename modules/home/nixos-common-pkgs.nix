{ pkgs, ... }:

{
  home.packages = with pkgs; [
    spotify
    zoom-us
    anydesk

    # Image viewer
    imv
    # Video player
    mpv
    # Others
    zoom-us
  ];
}

