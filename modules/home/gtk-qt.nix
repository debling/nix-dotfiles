{ pkgs, ... }:

let 
    iconPkg = pkgs.papirus-icon-theme.override { color = "green"; };
in
{
home.packages = [ iconPkg ];
 home.pointerCursor = {
   enable = true;
   gtk.enable = true;
   name = "BreezeX-RosePine-Linux";
   size = 24;
   package = pkgs.rose-pine-cursor;
 };

#  qt = {
#    enable = pkgs.stdenv.isLinux;
#    platformTheme.name = "adwaita";
#    style = {
#      package = [ pkgs.adwaita-qt ];
#      name = "adwaita-dark";
#    };
#  };
  gtk = {
    enable = true;
    theme = {
      name = "Colloid-Green-Dark-Gruvbox";
      package = pkgs.colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        themeVariants = [ "green" ];
        tweaks = [
          "gruvbox"
          "rimless"
          "float"
        ];
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = iconPkg;
    };
  };
}
