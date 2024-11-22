{ config, lib, pkgs, ... }:


let
  dwlb = pkgs.callPackage ./dwlb.nix { };
  dwl-patches = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "dwl";
    repo = "dwl-patches";
      rev = "9dc4bb37dabedf0859aaee8102f739da2d51e05a";
  hash = "sha256-D/2A5inrTXvaG54CBfn4Ff1zJnzYNpVylvZhy67HylI=";
  };
  dwl-with-patches = pkgs.dwl.overrideAttrs (prev: {
    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "dwl";
      repo = "dwl";
      rev = "1d08ade13225343890e3476f7c4003ab87dc266c";
      hash = "sha256-MoPU8SeIBHEf9kNu0xyuW1F/wTPEgpcWMGSAje3PFEU=";
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
    ];

    passthru = {
      providedSessions = [ prev.meta.mainProgram ];
    };
  });

  dwl = dwl-with-patches.override {
    configH = ./config.def.h;
  };

  dwl-run = pkgs.writeShellScriptBin "dwl-run" ''
    set -x

    systemctl --user is-active dwl-session.target \
      && echo "DWL is already running" \
      && exit 1

    # The commands below were adapted from:
    # https://github.com/NixOS/nixpkgs/blob/ad3e815dfa9181aaa48b9aa62a00cf9f5e4e3da7/nixos/modules/programs/wayland/sway.nix#L122
    # Import the most important environment variables into the D-Bus and systemd
    dbus-run-session -- ${lib.getExe dwl} -s "
      dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE;
      systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE;
      systemctl --user start dwl-session.target;
    " & 
    dwlPID=$!
    wait $dwlPID
    systemctl --user stop dwl-session.target
  '';

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";

    runtimeInputs = with pkgs; [ grim slurp satty ];

    text = ''
      grim -g "$(slurp -c '#ff0000ff')" -t ppm - \
        | satty --filename - \
                --fullscreen \
                --output-filename "$HOME/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png";
    '';
  };
in
{
  config = {
    environment = {
      systemPackages = [
        pkgs.slurp
        pkgs.grim
        screenshot
        pkgs.wl-clipboard
        dwl-run
        dwl
        dwlb
        pkgs.slstatus
        pkgs.brightnessctl
        pkgs.bemenu
        pkgs.libnotify
        pkgs.foot
        pkgs.playerctl
        pkgs.brightnessctl
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
      restartIfChanged = true;
    };

    systemd.user.services.status-bar = {
      description = "Service to run the status bar provider";
      enable = true;
      script = "${lib.getExe pkgs.slstatus} -s | ${lib.getExe dwlb} -status-stdin all -ipc";
      bindsTo = [ "dwlb.service" ];
      wantedBy = [ "dwlb.service" ];
      restartIfChanged = true;
    };

    security = {
      polkit.enable = true;
    };

    programs = {
      dconf.enable = true;
      xwayland.enable = true;
    };

    services.graphical-desktop.enable = true;

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

    home-manager.users.debling = {
      services.cliphist.enable = true;
    };

    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  };
}
