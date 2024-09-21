{ config, lib, pkgs, ... }:


let
  dwlb = pkgs.callPackage ./dwlb.nix { };
  dwl-patches = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl-patches";
    rev = "3c690cfb8bd744006ab8e49d23c8d4a9408ea66a";
    hash = "sha256-syiHhCedW1Jl42UBdBAdBxmiXwEKYBfqV2JrQLhilNY=";
  };
  dwl-with-patches = pkgs.dwl.overrideAttrs {
    patches = [
      # "${dwl-patches.outPath}/patches/unclutter/unclutter.patch"
    ];
  };

  dwl = dwl-with-patches.override {
    configH = ./config.def.h;
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
      systemPackages = [
        dwl
        dwlb
        pkgs.slstatus
        pkgs.brightnessctl
        pkgs.bemenu
      ];
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
