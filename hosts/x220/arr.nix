{
  config,
  lib,
  pkgs,
  ...
}:

let
  makeNginxLocalProxy = port: {
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };

  commonSettingsFor = name: {
    auth = {
      Enabled = false;
      Method = "External";
      Required = false;
    };
    postgres = {
      host = "localhost";
      user = name;
      password = name;
      maindb = name;
      logdb = name;
    };
  };
in
{
  users.groups.media = { };
  services.transmission = {
    enable = true;
    group = "media";
    package = pkgs.transmission_4;
    openRPCPort = true;
    settings = {
      rpc-host-whitelist-enabled = false;
      download-dir = "/srv/media/downloads";
      incomplete-dir = "/srv/media/incomplete";
      incomplete-dir-enabled = true;
      umask = 2; # group writable
    };
  };

  services.nginx.virtualHosts."transmission.home.debling.com.br" =
    makeNginxLocalProxy config.services.transmission.settings.rpc-port;
  # networking.firewall.allowedTCPPorts = [ 51413 ];
  # services.transmission.settings.peer-port = 51413;

  services.bazarr = {
    enable = true;
    group = "media";
    # settings = commonSettingsFor "bazarr";
  };

  services.nginx.virtualHosts."bazarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.bazarr.listenPort;

  services.sonarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "sonarr";
  };

  services.nginx.virtualHosts."sonarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.sonarr.settings.server.port;

  services.prowlarr = {
    enable = true;
    settings = commonSettingsFor "prowlarr";
  };
  services.nginx.virtualHosts."prowlarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.prowlarr.settings.server.port;

  services.lidarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "lidarr";
  };
  services.nginx.virtualHosts."lidarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.lidarr.settings.server.port;

  services.radarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "radarr";
  };
  services.nginx.virtualHosts."radarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.radarr.settings.server.port;

  services.readarr = {
    enable = true;
    group = "media";
    settings = {
    auth = {
      Enabled = false;
      Method = "External";
      Required = false;
    };
    }; 
  };
  services.nginx.virtualHosts."readarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.readarr.settings.server.port;

  services.seerr = {
    enable = true;
  };
  services.nginx.virtualHosts."seerr.home.debling.com.br" =
    makeNginxLocalProxy config.services.seerr.port;

  services.jellyfin = {
    enable = true;
    group = "media";
    hardwareAcceleration = {
        enable = true;
        type = "vaapi";
        device = "/dev/dri/renderD12";
    };
  };

    nixpkgs.config.packageOverrides = pkgs: {
        intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
    };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."jellyfin.home.debling.com.br" = {
    forceSSL = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
    };
  };
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "i965";
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "i965"; };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
        intel-ocl
        intel-vaapi-driver
        libva-vdpau-driver
        intel-compute-runtime-legacy1
    ];
  };
  users.users.jellyfin.extraGroups = [ "video" ];

  systemd.tmpfiles.rules = [
    "d /srv/media 2775 root media -"
    "d /srv/media/downloads 2775 root media -"
    "d /srv/media/incomplete 2775 root media -"
    "d /srv/media/tv 2775 root media -"
    "d /srv/media/movies 2775 root media -"
    "d /srv/media/music 2775 root media -"
    "d /srv/media/books 2775 root media -"
  ];

  services.homepage-dashboard.services = [
    {
      Media =
        let
          services = [
            "sonarr"
            "bazarr"
            "radarr"
            "prowlarr"
            "transmission"
            "jellyfin"
            "lidarr"
            "seerr"
            "readarr"
          ];
        in
        map (s: ({
          ${s} = {
            href = "https://${s}.home.debling.com.br";
            icon = s;
          };
        })) services;
    }
  ];

}
