{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name = "BreezeX-RosePine-Linux";
    size = 24;
    package = pkgs.rose-pine-cursor;
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
