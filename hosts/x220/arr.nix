{
  config,
  pkgs,
  serverUtils,
  ...
}:

let
  commonSettingsFor = name: {
    auth = {
      Enabled = false;
      Method = "External";
      Required = false;
    };
    log.dbenabled = false;
    postgres = {
      host = "127.0.0.1";
      user = name;
      password = name;
      maindb = name;
      logdb = name;
    };
  };
in
{
  virtualisation.oci-containers.containers.byparr = {
    image = "ghcr.io/thephaseless/byparr:latest";
    autoStart = true;
    environment = {
      TZ = "America/Sao_Paulo";
      LOG_LEVEL = "info";
      HOST = "127.0.0.1";
      PORT = "8191";
    };
    extraOptions = [ "--network=host" "--shm-size=2g" ];
  };

  # Fixed gid: the ryzen CIFS mount (hosts/ryzen/media-share.nix) maps the
  # share onto this group, and macOS's fruit/streams_xattr persists
  # numeric uid/gid into the files' xattrs, so the numbers must be stable.
  users.groups.media = {
    gid = 1200;
  };
  services.transmission = {
    enable = true;
    group = "media";
    package = pkgs.transmission_4;
    settings = {
      rpc-host-whitelist-enabled = false;
      download-dir = "/srv/media/downloads";
      incomplete-dir = "/srv/media/incomplete";
      incomplete-dir-enabled = true;
      umask = 2; # group writable
    };
  };

  services.nginx.virtualHosts."transmission.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.transmission.settings.rpc-port;
  # networking.firewall.allowedTCPPorts = [ 51413 ];
  # services.transmission.settings.peer-port = 51413;

  services.bazarr = {
    enable = true;
    group = "media";
    # settings = commonSettingsFor "bazarr";
  };

  services.nginx.virtualHosts."bazarr.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.bazarr.listenPort;

  services.sonarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "sonarr";
  };

  services.nginx.virtualHosts."sonarr.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.sonarr.settings.server.port;

  services.prowlarr = {
    enable = true;
    settings = commonSettingsFor "prowlarr";
  };
  services.nginx.virtualHosts."prowlarr.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.prowlarr.settings.server.port;

  services.lidarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "lidarr";
  };
  services.nginx.virtualHosts."lidarr.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.lidarr.settings.server.port;

  services.radarr = {
    enable = true;
    group = "media";
    settings = commonSettingsFor "radarr";
  };
  services.nginx.virtualHosts."radarr.home.debling.com.br" =
    serverUtils.makeNginxAuthProxy config.services.radarr.settings.server.port;

  services.seerr = {
    enable = true;
  };
  # Plain local proxy, NOT the Authelia barrier: seerr has no OIDC or
  # forward-auth support upstream (seerr-team/seerr #183), so behind the
  # barrier every login showed Authelia + seerr's own Jellyfin-backed login.
  # Protection is seerr's own login (Jellyfin credentials / Quick Connect).
  services.nginx.virtualHosts."seerr.home.debling.com.br" =
    serverUtils.makeNginxLocalProxy config.services.seerr.port;

  # NOTE: Jellyfin moved to the ryzen host (See hosts/ryzen/jellyfin.nix).
  # x220 remains the ingress: nginx proxies jellyfin.home.debling.com.br to
  # ryzen:8096, DNS still points the hostname here, and authelia's OIDC
  # "jellyfin" client registration is unchanged (hosts/x220/sso.nix).
  services.nginx.virtualHosts."jellyfin.home.debling.com.br" = {
    forceSSL = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://10.0.10.2:8096"; # ryzen
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/media 2775 root media -"
    "d /srv/media/downloads 2775 root media -"
    "d /srv/media/incomplete 2775 root media -"
    "d /srv/media/tv 2775 root media -"
    "d /srv/media/movies 2775 root media -"
    "d /srv/media/music 2775 root media -"
    "d /srv/media/books 2775 root media -"
  ];

}
