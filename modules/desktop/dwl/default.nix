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
  dwl-with-patches = pkgs.dwl.overrideAttrs (prev: {
    patches = [
      "${dwl-patches}/patches/ipc/ipc.patch"
      "${dwl-patches}/patches/autostart/autostart.patch"
    ];
    
    passthru = {
      providedSessions = [ prev.meta.mainProgram ];
    };
  });

  dwl = dwl-with-patches.override {
    configH = ./config.def.h;
  };

  dwl-run = pkgs.writeShellScriptBin "dwl-run" ''
    ${lib.getExe dwl} &
    waitPID=$!
    ${lib.getExe dwlb} -ipc -font 'mono:size=10' &
    sleep 1
    systemctl --user start dwl-session.target
    echo dwl session started
    wait $waitPID
    wait
    systemctl --user stop dwl-session.target
  '';
in
{
  config = {
    environment = {
      systemPackages = [
        pkgs.wl-clipboard
        dwl-run
        dwl
        dwlb
        pkgs.slstatus
        pkgs.brightnessctl
        pkgs.bemenu
        pkgs.libnotify
        pkgs.foot
      ];
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
      };
    };

    services.displayManager.sessionPackages = [ dwl ];
    
    systemd.user.targets.dwl-session = {
      description = "dwl compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };

    systemd.user.services.dwlb = {
      description = "Service to run the dwlb status bar";
      enable = true;
      serviceConfig = {
        ExecStart = "${lib.getExe dwlb} -ipc -font 'mono:size=10'";
      };
      bindsTo = [ "dwl-session.target" ];
      wantedBy = [ "dwl-session.target" ];
    };

    security = {
      polkit.enable = true;
    };

    programs = {
      dconf.enable = true;
      xwayland.enable = true;
    };

    services.graphical-desktop.enable = true;

    xdg.portal.wlr.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  };
}
