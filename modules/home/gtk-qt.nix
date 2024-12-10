{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
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
