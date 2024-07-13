{ config, lib, pkgs, ... }:


let 
    dwl = pkgs.dwl.override { conf = ./config.def.h; };
in {
  config = {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    environment = {
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
      };
    };

    services.greetd = {
      enable = true;
      settings =
        let
          tuigreet = lib.getExe pkgs.greetd.tuigreet;
          session = lib.getExe pkgs.dwl;
          username = "debling";
        in
        {
          initial_session = {
            command = "${session}";
            user = "${username}";
          };
          default_session = {
            command = "${tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd ${session}";
          };
        };
    };
  };
}
