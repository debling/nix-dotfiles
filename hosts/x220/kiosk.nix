{
  config,
  pkgs,
  ...
}:
let
  # Kiosk URL: Node Exporter Full (provisioned in observability.nix).
  # `kiosk` hides all Grafana chrome; `refresh=30s` keeps the data live.
  grafanaKioskUrl = "https://grafana.home.debling.com.br/d/rYdddlPWk/node-exporter-full?kiosk&refresh=30s";
in
{
  # Kiosk: render a Grafana dashboard on the external VGA monitor.
  # cage (single-app Wayland kiosk) logs the kiosk user in via PAM on tty1;
  # the built-in LVDS panel is forced off at boot so the VGA monitor is the
  # only output. NOTE: the kernel param takes effect on reboot, not on
  # `nixos-rebuild switch` alone.

  users.users.kiosk = {
    isNormalUser = true;
    description = "Grafana kiosk";
    hashedPassword = "!";
  };

  boot.kernelParams = [ "video=LVDS-1:d" ];

  # The server ships no fonts at all; Chromium needs something to render
  # (Grafana serves its own webfonts for the panels themselves).
  fonts.packages = with pkgs; [
    dejavu_fonts
    noto-fonts-color-emoji
  ];

  services.cage = {
    enable = true;
    user = "kiosk";
    restartIfChanged = true;
    # Single-output kiosk: "-m last" uses the only enabled output (the VGA,
    # since the LVDS panel is forced off above).
    extraArguments = [
      "-m"
      "last"
    ];
    environment = {
      NIXOS_OZONE_WL = "1"; # chromium renders natively on Wayland (no Xwayland)
      XDG_SESSION_TYPE = "wayland";
    };
    program = pkgs.writeShellScript "grafana-kiosk" ''
      exec ${pkgs.chromium}/bin/chromium \
        --kiosk \
        --no-first-run \
        --no-default-browser-check \
        --noerrdialogs \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --hide-crash-restore-bubble \
        --overscroll-history-navigation=0 \
        --disable-features=Translate,MediaRouter \
        --user-data-dir=/var/lib/kiosk-chromium \
        '${grafanaKioskUrl}'
    '';
  };

  # Restart on crash and when the monitor is unplugged (cage exits when its
  # last output disappears); it retries every 5s until the monitor is back.
  systemd.services."cage-tty1".serviceConfig = {
    Restart = "always";
    RestartSec = 5;
    StateDirectory = "kiosk-chromium";
  };
}
