{
  config,
  pkgs,
  mainUser,
  ...
}:
let
  width = 1920;
  height = 1080;

  swayConfig = pkgs.writeText "steam-headless-sway.conf" ''
    output HEADLESS-1 mode ${toString width}x${toString height}@60Hz
    default_border none
    for_window [class="^steam$"] fullscreen enable
    bar {
      mode invisible
    }
  '';

  sessionScript = pkgs.writeShellScriptBin "steam-headless-session" ''
    export WLR_BACKENDS=headless,libinput
    export WLR_LIBINPUT_NO_DEVICES=1
    ${pkgs.sway}/bin/sway -c ${swayConfig} &
    sway_pid=$!
    for i in $(seq 1 60); do
      [ -S "''${XDG_RUNTIME_DIR}/wayland-1" ] && break
      sleep 0.5
    done
    for i in $(seq 1 60); do
      DISPLAY=:0 ${pkgs.xorg.xset}/bin/xset q >/dev/null 2>&1 && break
      sleep 0.5
    done
    export DISPLAY=:0
    systemctl --user restart sunshine
    while kill -0 $sway_pid 2>/dev/null; do
      ${config.programs.steam.package}/bin/steam -gamepadui < /dev/null
      sleep 2
    done
    systemctl --user stop sunshine
    kill $sway_pid 2>/dev/null
  '';
in
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    nvidiaPersistenced = true;
    nvidiaSettings = false;
  };

  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      initial_session = {
        user = mainUser;
        command = "${sessionScript}/bin/steam-headless-session";
      };
      default_session = {
        user = "greeter";
        command = "${pkgs.tuigreet}/bin/tuigreet --time";
      };
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  services.sunshine = {
    enable = true;
    openFirewall = true;
    settings.capture = "wlr";
  };

  systemd.user.services.sunshine.serviceConfig.Environment = [
    "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
    "WAYLAND_DISPLAY=wayland-1"
  ];
}
