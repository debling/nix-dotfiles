{ config, lib, pkgs, ... }:


let
  dwlb = pkgs.callPackage ./dwlb.nix { };
  dwl-patches = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl-patches";
    rev = "5252fe728ed5bc62ba70bd2c9b0d36df074d20e9";
    hash = "sha256-mD4mc6CzJaN+Z+Kz5WHkRNNh7Q/OSWkt6BOZXlCoGj8=";
  };
  dwl = pkgs.dwl.override {
    # patches = [
    #   "${dwl-patches.outPath}/patches/bar/bar.patch"
    # ];
    conf = ./config.def.h;
  };
in
{
  config = {
    programs.dconf.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };

    environment = {
      systemPackages = [ dwl dwlb ];
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
          session = "${lib.getExe dwl} -s '${lib.getExe dwlb} -font \"mono:size=10\"'";
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
