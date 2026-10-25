# Jellyfin on the ryzen host: NVENC/NVDEC on the GTX 1050 Ti.
#
# The media tree is /srv/media, the same path x220 uses so the migrated
# library DB needs no rescans — see media-share.nix for the CIFS mount.
{
  config,
  lib,
  ...
}:

{
  imports = [ ../../modules/nixos/jellyfin-sso.nix ];

  services.jellyfin = {
    enable = true;
    # The migrated encoding.xml came from x220 with vaapi configured; force
    # nix config to be the source of truth so nvenc is applied on restart.
    forceEncodingConfig = true;
    transcoding = {
      # GTX 1050 Ti (Pascal): NVENC H.264 (2 concurrent sessions) + HEVC
      # Main/Main10 encode; NVDEC covers h264/hevc/vp9. The library is
      # pre-normalized to 1080p H.264 8-bit by tdarr, which is the ideal
      # NVENC workload. NOTE: legacy_580 driver (see steam-headless.nix,
      # open=false) is the right one for this card.
      enableHardwareEncoding = true;
      # Pascal NVENC cannot encode AV1 — leave that off.
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
      # The module's DeviceAllow expects a single render node (VAAPI-style);
      # NVIDIA transcode needs the full device set, so override it below.
      device = "/dev/nvidiactl";
      type = "nvenc";
    };
  };

  # The upstream module hard-sets the nvidia device allowlist to one node;
  # assign it explicitly to all nvidia devices jellyfin-ffmpeg's NVENC/NVDEC
  # paths need.
  systemd.services.jellyfin = {
    unitConfig.RequiresMountsFor = [ "/srv/media" ];
    serviceConfig.DeviceAllow = lib.mkForce [
      "/dev/nvidia0 rw"
      "/dev/nvidiactl rw"
      "/dev/nvidia-uvm rw"
    ];
    # jellyfin's network.xml ships empty KnownProxies; since the public
    # ingress (x220 nginx) is no longer same-host, register x220 so
    # X-Forwarded-For real client IPs are trusted (remote access rules,
    # activity logs).
    preStart = lib.mkAfter ''
      sed -i "s|<KnownProxies \\?/>|<KnownProxies>10.0.10.1</KnownProxies>|" ${config.services.jellyfin.configDir}/network.xml
    '';
  };

  # PrivateUsers (set by the upstream module) keeps this a pure user
  # namespace; read access to /srv/media only needs the group mapping.
  users.users.jellyfin.extraGroups = [ "media" ];

  # Expose 8096 to x220 so its nginx can reverse-proxy
  # jellyfin.home.debling.com.br here. Keep it off tailscale0 the way x220
  # does: reach jellyfin only through the https ingress.
  networking.firewall.interfaces."enp37s0".allowedTCPPorts = [ 8096 ];
}
