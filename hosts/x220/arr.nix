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
  };

  services.nginx.virtualHosts."bazarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.bazarr.listenPort;

  services.sonarr = {
    enable = true;
    group = "media";
    settings = {
      auth = {
        AuthenticationEnabled = false;
        AuthenticationMethod = "external";
      };
    };
  };

  services.nginx.virtualHosts."sonarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.sonarr.settings.server.port;

  services.prowlarr = {
    enable = true;
    settings = {
      auth = {
        AuthenticationMethod = "external";
      };
    };
  };
  services.nginx.virtualHosts."prowlarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.prowlarr.settings.server.port;

  services.lidarr = {
    enable = true;
    group = "media";
    settings = {
      auth = {
        AuthenticationEnabled = false;
        AuthenticationMethod = "external";
      };
    };
  };
  services.nginx.virtualHosts."lidarr.home.debling.com.br" =
    makeNginxLocalProxy config.services.lidarr.settings.server.port;

  services.jellyfin = {
    enable = true;
    group = "media";
  };
  services.nginx.virtualHosts."jellyfin.home.debling.com.br" = {
    forceSSL = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  users.users.jellyfin.extraGroups = [ "video" ];

  systemd.tmpfiles.rules = [
    "d /srv/media 2775 root media -"
    "d /srv/media/downloads 2775 root media -"
    "d /srv/media/incomplete 2775 root media -"
    "d /srv/media/tv 2775 root media -"
    "d /srv/media/music 2775 root media -"
  ];

  services.homepage-dashboard.services = [
    {
      Media =
        let
          services = [
            "sonarr"
            "bazarr"
            "prowlarr"
            "transmission"
            "jellyfin"
            "lidarr"
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
