{
  config,
  pkgs,
  mainUser,
  ...
}:
let
  width = 1920;
  height = 1080;

  steamSession = pkgs.writeShellScriptBin "steam-headless-session" ''
    ${pkgs.xorg.xset}/bin/xset s off
    ${pkgs.xorg.xset}/bin/xset -dpms
    ${config.programs.steam.package}/bin/steam -gamepadui &
    steam_pid=$!
    while kill -0 $steam_pid 2>/dev/null; do
      wid_hex=$(${pkgs.xorg.xwininfo}/bin/xwininfo -root -tree 2>/dev/null | grep '"Steam Big Picture Mode"' | grep -oE '0x[0-9a-f]+' | head -1)
      if [ -n "$wid_hex" ]; then
        wid=$((wid_hex))
        ${pkgs.xdotool}/bin/xdotool windowsize "$wid" ${toString width} ${toString height} 2>/dev/null
        ${pkgs.xdotool}/bin/xdotool windowmove "$wid" 0 0 2>/dev/null
      fi
      sleep 5
    done
    wait $steam_pid
  '';

  steamHeadlessSession =
    pkgs.runCommand "steam-headless-session"
      {
        passthru.providedSessions = [ "steam-headless" ];
      }
      ''
        mkdir -p $out/bin $out/share/xsessions
        install -Dm755 ${steamSession}/bin/steam-headless-session $out/bin/steam-headless-session
        {
          echo '[Desktop Entry]'
          echo 'Type=Application'
          echo 'Name=Steam Headless'
          echo 'Comment=Headless Steam Remote Play host'
          echo 'Exec='"$out"'/bin/steam-headless-session'
        } > $out/share/xsessions/steam-headless.desktop
      '';
in
{
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    deviceSection = ''
      Option "AllowEmptyInitialConfiguration" "true"
      Option "ConnectedMonitor" "DFP-0"
    '';

    monitorSection = ''
      HorizSync 30-80
      VertRefresh 50-75
      Modeline "1920x1080_60" 148.50 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync
    '';

    screenSection = ''
      Option "MetaModes" "DFP-0: 1920x1080_60 +0+0"
    '';
  };

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    nvidiaPersistenced = true;
    nvidiaSettings = false;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  services.displayManager = {
    sessionPackages = [ steamHeadlessSession ];
    defaultSession = "steam-headless";
    autoLogin.user = mainUser;
    sddm = {
      enable = true;
      autoLogin.relogin = true;
    };
  };
}
