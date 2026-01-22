{
  config,
  pkgs,
  colorscheme,
  mainUser,
  ...
}:

{

  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  environment.systemPackages =
    let
      volume = pkgs.writeShellApplication {
        name = "volume";
        runtimeInputs = with pkgs; [
          libnotify
          pipewire
        ];
        text = builtins.readFile ./volume;
      };

      screenshot = pkgs.writeShellApplication {
        name = "screenshot";

        runtimeInputs = with pkgs; [
          grim
          slurp
          satty
        ];

        text = # sh
          ''
            grim -g "$(slurp -c '#ff0000ff')" -t ppm - \
              | satty --filename - \
              --fullscreen \
              --output-filename "$HOME/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";
          '';
      };
    in
    with pkgs;
    [
      volume
      screenshot
      kooha # recording tool
      wf-recorder
      hyprshot
      pamixer
      slurp
      grim
      wl-clipboard
      playerctl
      brightnessctl
      wdisplays
      satty
      libnotify
    ];

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      };
    };
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  home-manager.users.${mainUser} = {
    # systemd.user.services.wbg = {
    #   Unit = {
    #     Description = "Service to set the wallpapper";
    #     PartOf = [ "graphical-session.target" ];
    #   };
    #   Service.ExecStart =
    #     let
    #       nix-colors-lib = nix-colors.lib.contrib { inherit pkgs; };
    #       wallpaper = nix-colors-lib.nixWallpaperFromScheme {
    #         scheme = colorscheme;
    #         width = 3840;
    #         height = 2160;
    #         logoScale = 4.0;
    #       };
    #     in
    #     "${lib.getExe pkgs.wbg} --stretch ${wallpaper}";
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
    services = {
      mako = with colorscheme.palette; {
        enable = true;
        settings = {
          default-timeout = 10 * 1000;
          layer = "overlay";
          icon-path = "${pkgs.rose-pine-icon-theme}/share/icons/rose-prine-dawn";
          background-color = "#${base00}";
          text-color = "#${base05}";
          border-color = "#${base0D}";
          progress-color = "#${base02}";
          "urgency=low" = {
            background-color = "#${base00}";
            text-color = "#${base0A}";
            border-color = "#${base0D}";
          };

          "urgency=high" = {
            background-color = "#${base00}";
            text-color = "#${base08}";
            border-color = "#${base0D}";
          };
        };
      };
      wpaperd = {
        enable = true;
        settings = {
          default = {
            path = ../../../wallpapers;
            duration = "30m";
            transition-time = 1000;
          };
        };
      };
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
