{ serverUtils, ... }:
let
  # 3000 is Grafana.
  port = 3001;
in
{
  services.forgejo = {
    enable = true;
    # Postgres DB + user are auto-provisioned by the module
    # (createDatabase defaults to true, socket auth via /run/postgresql).
    database.type = "postgres";
    settings = {
      server = {
        DOMAIN = "forgejo.home.debling.com.br";
        ROOT_URL = "https://forgejo.home.debling.com.br/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = port;
        # No SSH server for now: the built-in server rejects valid keys
        # silently (suspected upstream issue); git over HTTPS works.
        # Follow-up: host-openssh integration or re-test after upgrade.
        DISABLE_SSH = true;
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
    # Daily dumps to /var/lib/forgejo/dump.
    dump.enable = true;
  };

  services.nginx.virtualHosts."forgejo.home.debling.com.br" =
    serverUtils.makeNginxLocalProxy port
    // {
      # Allow pushes / releases / LFS objects (nginx default is 1m).
      extraConfig = "client_max_body_size 512M;";
    };
}
