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
    serverUtils.localProxyWith config.services.paperless.port {
      extraConfig = "client_max_body_size 100M;";
    };

  services.postgresql = {
    ensureDatabases = [ "paperless" ];
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
  };
}