{ lib, pkgs, nix-colors, colorscheme, mainUser, ... }:

{
  environment.systemPackages = let 
    volume = pkgs.writeShellApplication {
      name = "volume";
      runtimeInputs = with pkgs; [ libnotify pipewire ];
      text = builtins.readFile ./volume;
    };

    screenshot = pkgs.writeShellApplication {
      name = "screenshot";

      runtimeInputs = with pkgs; [ grim slurp satty ];

      text = /* sh */ ''
        grim -g "$(slurp -c '#ff0000ff')" -t ppm - \
          | satty --filename - \
          --fullscreen \
          --output-filename "$HOME/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";
      '';
    };
  in
    with pkgs; [
      volume
      screenshot

      pamixer
      slurp
      grim
      wl-clipboard
      playerctl
      brightnessctl
      wdisplays
    ];

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = "wlr";
      };
    };
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };


  home-manager.users.${mainUser} = {

    systemd.user.services.wbg = {
      Unit = {
        Description = "Service to set the wallpapper";
        PartOf = [ "graphical-session.target" ];
      };
      Service.ExecStart =
        let
          nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
          wallpaper = nix-colors-lib.nixWallpaperFromScheme {
            scheme = colorscheme;
            width = 3840;
            height = 2160;
            logoScale = 4.0;
          };
        in
        "${lib.getExe pkgs.wbg} --stretch ${wallpaper}";
      Install.WantedBy = [ "graphical-session.target" ];
    };

    services = {
      cliphist.enable = true;
      wlsunset = {
        enable = true;
        latitude = -29.6;
        longitude = -53.7;
        temperature.night = 4500;
      };
    };
  };
}

