{ lib, pkgs, nix-colors, colorscheme, ... }:


let
  dwlb = pkgs.callPackage ./dwlb.nix { };
  # main - 29-12-2024
  dwl-patches = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl-patches";
    rev = "919741ee198dc2894d14ff9d1131ac36dc8d39d7";
    hash = "sha256-WPnoE7y2H5vhLbNAU6vrz0YZa6gN9WcikRDYxFfXO7M=";
  };
  dwl-with-patches = pkgs.dwl.overrideAttrs (prev: {
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dwl";
      repo = "dwl";
      rev = "aa69ed81b558f74e470e69cdcd442f9048ee624c";
      hash = "sha256-qO7k2Sj4nWrXrM2FwNkgnAK2D76bIWa2q625k3jDBUA=";
    };
    buildInputs = with pkgs; [
      libinput
      xorg.libxcb
      libxkbcommon
      pixman
      wayland
      wayland-protocols
      wlroots
      xorg.libX11
      xorg.xcbutilwm
      xwayland
    ];

    patches = [
      "${dwl-patches}/patches/ipc/ipc.patch"
      "${dwl-patches}/patches/smartborders/smartborders.patch"
      "${dwl-patches}/patches/kblayout/kblayout.patch"
    ];

    passthru = {
      providedSessions = [ prev.meta.mainProgram ];
    };
  });

  dwl = dwl-with-patches.override {
    configH = ./config.def.h;
  };

  slstatus = pkgs.slstatus.override {
    conf = ./slstatus-config.h;
  };


  dwl-run = pkgs.writeShellScriptBin "dwl-run" ''
    set -x

    systemctl --user is-active dwl-session.target \
      && echo "DWL is already running" \
      && exit 1

    # The commands below were adapted from:
    # https://github.com/NixOS/nixpkgs/blob/ad3e815dfa9181aaa48b9aa62a00cf9f5e4e3da7/nixos/modules/programs/wayland/sway.nix#L122
    # Import the most important environment variables into the D-Bus and systemd
    ${lib.getExe dwl} -s "
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE;
      systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE;
      systemctl --user start dwl-session.target;
    " & 
    dwlPID=$!
    wait $dwlPID
    systemctl --user stop dwl-session.target
  '';

in
{
  imports = [ ../common.nix ];
  config = {
    environment = {
      systemPackages = [
        pkgs.slurp
        pkgs.grim
        screenshot
        volume
        pkgs.wl-clipboard
        dwl-run
        dwl
        dwlb
        slstatus
        pkgs.bemenu
        pkgs.libnotify
        pkgs.playerctl
        pkgs.brightnessctl
        pkgs.wdisplays
      ];
      sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        # Hint electron apps to use wayland
        NIXOS_OZONE_WL = "1";
      };
    };

    services.displayManager.sessionPackages = [
      ((pkgs.writeTextDir "share/wayland-sessions/dwl.desktop" ''
        [Desktop Entry]
        Name=dwl
        Exec=dwl-run
        Type=Application
      '').overrideAttrs (_: { passthru.providedSessions = [ "dwl" ]; }))
    ];

    systemd.user.targets.dwl-session = {
      description = "dwl compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" "xdg-desktop-autostart.target" ];
      after = [ "graphical-session-pre.target" ];
      before = [ "xdg-desktop-autostart.target" ];
    };

    systemd.user.services.dwlb = {
      enable = true;
      description = "Service to run the dwlb status bar";
      serviceConfig = {
        ExecStart = with colorscheme.palette; ''
          ${lib.getExe dwlb} -ipc -font 'mono:size=8' \
            -inactive-fg-color '#${base06}' \
            -inactive-bg-color '#${base03}' \
            -middle-bg-color '#${base00}' \
            -middle-bg-color-selected '#${base00}' \
            -active-fg-color '#${base06}' \
            -active-bg-color '#${base00}' \
            -occupied-fg-color '#${base06}' \
            -occupied-bg-color '#${base03}'
        '';
      };
      bindsTo = [ "dwl-session.target" ];
      wantedBy = [ "dwl-session.target" ];
    };

    systemd.user.services.status-bar = {
      description = "Service to run the status bar provider";
      enable = true;
      script = "${lib.getExe slstatus} -s | ${lib.getExe dwlb} -status-stdin all -ipc";
      bindsTo = [ "dwlb.service" ];
      wantedBy = [ "dwlb.service" ];
      restartTriggers = [ dwlb slstatus ];
    };

    security = {
      polkit.enable = true;
    };

    services.graphical-desktop.enable = true;

    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  };
}
