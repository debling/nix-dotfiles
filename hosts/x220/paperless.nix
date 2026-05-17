{ config, pkgs, serverUtils, ... }:
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
    serverUtils.makeNginxLocalProxy config.services.paperless.port;

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