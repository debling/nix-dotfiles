{ lib, pkgs, ... }:

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

  # networking.firewall.allowedTCPPorts = [ 51413 ];
  # services.transmission.settings.peer-port = 51413;

  services.sonarr = {
    enable = true;
    group = "media";
    settings = {
      auth = {
        AuthenticationEnabled = false;
        AuthenticationMethod = "external";
      };
      server = {
        UrlBase = "sonarr";
      };
    };

  };


  services.prowlarr = {
    enable = true;
    settings = {
      auth = {
        AuthenticationMethod = "external";
      };
      server = {
        UrlBase = "prowlarr";
      };
    };
  };

  services.lidarr = {
    enable = true;
    group = "media";
    settings = {
      auth = {
        AuthenticationEnabled = false;
        AuthenticationMethod = "external";
      };
      server = {
        UrlBase = "lidarr";
      };
    };
  };



  services.overseerr = {
    enable = true;
  };

  services.jellyfin = {
    enable = true;
    group = "media";
  };

  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
  ];
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
          services = [ "sonarr" "prowlarr" "overseerr" "transmission" "jellyfin" "lidarr" ];
        in
        map (s: ({ ${s} = { href = "/${s}"; icon = s; }; })) services;
    }
  ];


}
