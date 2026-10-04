# Smart external-display + laptop-lid behavior for g15 (X11 + dwm), cloned
# from x1-carbon.
#
# TODO for g15: the EDIDs/fingerprints below are the x1-carbon panel and the
# LG UltraWide. Replace them for the G15's internal panel and any external
# display actually used (connect the display, `autorandr --fingerprint`).
# Until then unknown displays fall back to the `laptop-only` defaultTarget,
# which is safe but assumes the x1-carbon internal EDID matches.
#
# Desired behavior:
#   no HDMI + lid open    -> laptop-only (internal eDP-1 only)
#   no HDMI + lid closed   -> logind suspends
#   HDMI + lid open        -> dual (eDP-1 primary left, HDMI-1 right)
#   HDMI + lid closed      -> external-only (HDMI-1 primary, eDP-1 off, no suspend)
#
# How the pieces fit together:
# - logind owns suspend. HandleLidSwitchDocked=ignore wins over the
#   AC-power/battery checks (verified in systemd 261 sources: docked, i.e. a
#   mechanical dock OR >= 1 external DRM connector such as HDMI-A-*, is
#   evaluated first), so lid-closed + HDMI never suspends, on AC or battery.
#   While the lid stays closed logind keeps re-evaluating the lid action, so
#   unplugging HDMI with the lid closed suspends via HandleLidSwitch.
# - autorandr owns display layout. Its default matching already treats the
#   internal output as disconnected while the lid is closed, so plain
#   `autorandr --change` picks: {eDP} -> laptop-only, {eDP,HDMI} -> dual,
#   {HDMI} -> external-only, {} -> defaultTarget below.
# - defaultTarget = "laptop-only" re-enables the internal panel when nothing
#   matches (notably undock-with-lid-closed, where the setup is empty), so the
#   internal display is back before logind suspends. Unknown HDMI displays
#   fall back to internal-only too: always a working screen, never a missed
#   suspend. To give another display full behavior, fingerprint it (see below).
# - Triggers for `autorandr --change`, all converging on the same matching:
#   * DRM hotplug: services.autorandr's packaged udev rule starts the system
#     autorandr.service (root --batch re-execs as the session user, so no
#     DISPLAY/XAUTHORITY plumbing is needed).
#   * resume: the same service is wanted by sleep.target.
#   * session start: home-manager services.autorandr runs --change once the
#     graphical session is up (covers boot with HDMI/lid-closed already set).
#   * lid open/close: lid flips emit no DRM uevent, so services.acpid watches
#     button/lid.* and only *notifies* the user session (starts the HM user
#     unit); all xrandr work stays inside the graphical session.
{
  lib,
  pkgs,
  mainUser,
  ...
}:

let
  # Connector names as xrandr reports them (sysfs uses HDMI-A-1 for HDMI-1).
  internal = "eDP-1";
  external = "HDMI-1";

  # Fingerprints discovered on x1-carbon (do not guess these):
  # - eDP-1: full EDID from `xrandr --verbose` (AUO B140HAN03.2, 1920x1080).
  # - HDMI-1: full 256-byte EDID (base + CEA extension) reconstructed from the
  #   Xorg log's EDID dump for the connected LG UltraWide (GSM 7714, 2022,
  #   2560x1080, 80x34cm) at ~/.local/share/xorg/Xorg.0.log. Verify with
  #   `autorandr --fingerprint` while the display is connected.
  edid = {
    "eDP-1" =
      "00ffffffffffff0006af3d3100000000001a0104a51f1178028d15a156529d280a505400000001010101010101010101010101010101143780b87038244010103e0035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30332e31200a003b";
    "HDMI-1" =
      "00ffffffffffff001e6d1477847305000a20010380502278eaca95a6554ea1260f5054256b807140818081c0a9c0b300d1c08100d1cfcd4600a0a0381f4030203a001e4e3100001a023a801871382d40582c45001e4e3100001e000000fd00384b1e5a19000a202020202020000000fc004c472048445220574648440a20010a020337f1230907074c100403011f1359da125d5e5f830100006d030c002000b83c20006001020367d85dc4013c8000e305c000e3060501295900a0a038274030203a001e4e3100001a565e00a0a0a02950302035001e4e3100001a000000ff00323130415a4a5441483235320a00000000000000000000000000000000000074";
  };

  # NOTE on modes/rates: `mode` is pinned per output because autorandr crashes
  # on multi-output profiles without one. `rate` is deliberately left at the
  # preferred rate (what Xorg picks today: 60.05 on eDP-1, 60.0 on HDMI-1 per
  # xrandr/Xorg.0.log) so a slightly-off pinned rate can never fail the whole
  # profile application.
  #
  # NOTE on matching: autorandr matches a profile only if every fingerprinted
  # entry equals a connected output AND every connected output is listed, but
  # entries without a fingerprint are skipped. So each profile must list
  # exactly its fingerprinted outputs as `on`: an `off` line for a
  # non-fingerprinted output would make the profile also match setups where
  # that output is connected (all three profiles would match dual, with the
  # winner decided by config-mtime tiebreak). The eDP-1 disable for
  # external-only therefore lives in a postswitch hook, not in the config.
  #
  # Adding another HDMI display later: connect it, run
  # `autorandr --save <name>` (or `autorandr --fingerprint` for the EDID),
  # then extend the dual/external-only fingerprints + configs below.
in
{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  services.autorandr = {
    enable = true;
    defaultTarget = "laptop-only";
    profiles = {
      "laptop-only" = {
        fingerprint = {
          ${internal} = edid."eDP-1";
        };
        config = {
          ${internal} = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
        };
      };
      "dual" = {
        fingerprint = {
          ${internal} = edid."eDP-1";
          ${external} = edid."HDMI-1";
        };
        config = {
          ${internal} = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
          };
          ${external} = {
            enable = true;
            position = "1920x0";
            mode = "2560x1080";
          };
        };
      };
      "external-only" = {
        fingerprint = {
          ${external} = edid."HDMI-1";
        };
        config = {
          ${external} = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2560x1080";
          };
        };
        # Disables the internal panel on every external-only switch (see the
        # matching NOTE above: this cannot be an `off` config line). Runs
        # inside the graphical session as a child of autorandr, so DISPLAY is
        # inherited; the binary path is absolute anyway.
        hooks.postswitch."disable-internal" = ''
          ${pkgs.xrandr}/bin/xrandr --output ${internal} --off
        '';
      };
    };
  };

  # The module throttles to 1 start per 5s; hotplug flaps (dock fiddling)
  # would silently drop the second event and wedge the layout.
  systemd.services.autorandr.startLimitIntervalSec = lib.mkForce 10;
  systemd.services.autorandr.startLimitBurst = lib.mkForce 5;

  # Lid open/close emits no DRM uevent, so hook the ACPI lid button and wake
  # the *user* autorandr unit. This runs as root and must not touch X itself:
  # it only starts the user-session unit, where DISPLAY/XAUTHORITY are set.
  services.acpid = {
    enable = true;
    lidEventCommands = ''
      uid=$(${pkgs.coreutils}/bin/id -u "${mainUser}")
      if [ -S "/run/user/$uid/bus" ]; then
        XDG_RUNTIME_DIR="/run/user/$uid" ${pkgs.util-linux}/bin/runuser -u "${mainUser}" -w XDG_RUNTIME_DIR -- ${pkgs.systemd}/bin/systemctl --user --no-block start autorandr.service
      fi
    '';
  };

  # Run `autorandr --change` once the dwm graphical session is up, so boot
  # with HDMI connected and/or the lid closed lands on the right profile
  # (the system service only fires on hotplug + resume). Deliberately
  # without --default (unlike the system service): at session start the Xorg
  # fallback (all connected outputs on) is a safe state, and forcing
  # laptop-only here would kill an unknown external display on every login.
  home-manager.users.${mainUser} = {
    services.autorandr.enable = true;
  };
}
