{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ### Image viewer
    imv
    ### Video player
    mpv
    ### Music player
    cmus
    spotify-player

    ### Others
    anydesk
    libreoffice
    obsidian
    spotify
    zoom-us

    slack
  ];
}

