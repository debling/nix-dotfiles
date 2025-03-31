{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      corefonts # microsoft free fonts
      source-sans-pro
      source-serif-pro
      nerd-fonts.terminess-ttf
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMonoNL NF" ];
        sansSerif = [ "Source Sans Pro" ];
        serif = [ "Source Serif Pro" ];
      };
      hinting.style = "full";
      subpixel.rgba = "rgb";
    };
  };
}
