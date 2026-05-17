{ config, pkgs, ... }:

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
  services.paperless = {
    enable = true;
    settings = {
      PAPERLESS_DBHOST = "localhost";
      PAPERLESS_DBNAME = "paperless";
      PAPERLESS_DBUSER = "paperless";
      PAPERLESS_URL = "https://paperless.home.debling.com.br";
    };
  };

  services.nginx.virtualHosts."paperless.home.debling.com.br" =
    makeNginxLocalProxy config.services.paperless.port;

  services.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };

  services.homepage-dashboard.services = [
    {
      Geral = [
        { Paperless-ngx = { href = "https://paperless.home.debling.com.br"; icon = "paperless-ngx"; }; }
      ];
    }
  ];
}