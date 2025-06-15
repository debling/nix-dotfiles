{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "BreezeX-RosePine-Linux";
    size = 24;
    package = pkgs.rose-pine-cursor;
  };

  gtk = {
    enable = pkgs.stdenv.isLinux;
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine";
      package = pkgs.rose-pine-icon-theme;
    };
  };

  qt = {
    enable = pkgs.stdenv.isLinux;
    platformTheme.name = "adwaita";
    style = {
      package = [ pkgs.adwaita-qt ];
      name = "adwaita-dark";
    };
  };
}
