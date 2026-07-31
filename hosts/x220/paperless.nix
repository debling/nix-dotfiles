{
  config,
  pkgs,
  serverUtils,
  ...
}:
{
  services.paperless = {
    enable = true;
    domain = "paperless.home.debling.com.br";
    database.createLocally = true;
  };

  services.nginx.virtualHosts."paperless.home.debling.com.br" =
    serverUtils.localProxyWith config.services.paperless.port
      {
        extraConfig = "client_max_body_size 100M;";
      };
}
