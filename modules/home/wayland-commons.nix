{ pkgs, colorscheme, ...}: 

{
  home.packages = with pkgs; [
    # CLI utils
    cloc
    coreutils
    entr # Run commands when files change
    graphviz
    jq
    killall
    pinentry-tty
    # renameutils # adds qmv, and qmc utils for bulk move and copy
    rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
    silver-searcher # A faster and more convenient grep. Executable is called `ag`
    tree
    wget
    imagemagick

    # nix utils
    nurl # helper for creating fetch srcs from urls

    # required by telescope.nvim  
    ripgrep
    fd

    # Image viewer
    imv

    # Video player
    mpv

    # Others
    zoom-us
  ];
  

  services.mako = with colorscheme.palette; {
    enable = true;
    defaultTimeout = 10 * 1000;
    layer = "overlay";
    iconPath = "${pkgs.rose-pine-icon-theme}/share/icons/rose-prine-dawn";
    backgroundColor = "#${base00}";
    textColor = "#${base05}";
    borderColor = "#${base0D}";
    progressColor = "#${base02}";
    extraConfig = ''
        [urgency=low]
        background-color=#${base00}
        text-color=#${base0A}
        border-color=#${base0D}

        [urgency=high]
        background-color=#${base00}
        text-color=#${base08}
        border-color=#${base0D}
    '';
  };
}

