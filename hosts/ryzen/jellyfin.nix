{
  config,
  lib,
  ...
}:

{
  services.jellyfin = {
    enable = true;
    forceEncodingConfig = true;
    transcoding = {
      # GTX 1050 Ti (Pascal): NVENC H.264 (2 concurrent sessions) + HEVC
      # Main/Main10 encode; NVDEC covers h264/hevc/vp9. The library is
      # pre-normalized to 1080p H.264 8-bit by tdarr, which is the ideal
      # NVENC workload. NOTE: legacy_580 driver (see steam-headless.nix,
      # open=false) is the right one for this card.
      enableHardwareEncoding = true;
      hardwareEncodingCodecs.hevc = true;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        vp9 = true;
      };
      enableToneMapping = true;
    };
    hardwareAcceleration = {
      enable = true;
      device = "/dev/nvidiactl";
      type = "nvenc";
    };
  };
  systemd.services.jellyfin = {
    unitConfig.RequiresMountsFor = [ "/srv/media" ];
    serviceConfig.DeviceAllow = lib.mkForce [
      "/dev/nvidia0 rw"
      "/dev/nvidiactl rw"
      "/dev/nvidia-uvm rw"
    ];
    preStart = lib.mkAfter ''
      sed -i "s|<KnownProxies \\?/>|<KnownProxies>10.0.10.1</KnownProxies>|" ${config.services.jellyfin.configDir}/network.xml
    '';
  };

  users.users.jellyfin.extraGroups = [ "media" ];

  # Expose 8096 to x220 so its nginx can reverse-proxy
  # jellyfin.home.debling.com.br here. Keep it off tailscale0 the way x220
  # does: reach jellyfin only through the https ingress.
  networking.firewall.interfaces."enp37s0".allowedTCPPorts = [ 8096 ];
}
