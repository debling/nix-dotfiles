{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Image viewer
    imv
    # Video player
    mpv
    # Others
    anydesk
    libreoffice
    obsidian
    spotify
    zoom-us

    # experimental
    logseq
  ];
}

