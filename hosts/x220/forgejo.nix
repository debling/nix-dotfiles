{ config, pkgs, serverUtils, ... }:
let
  # 3000 is Grafana.
  port = 3001;
in
{
  age.secrets.forgejo-oidc.file = ../../secrets/forgejo-oidc.age;

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
      # New Authelia users get a Forgejo account on first OIDC login
      # (local signup form stays closed). Admins group maps to Forgejo admins.
      # ACCOUNT_LINKING=login guards against silent takeover on email match.
      oauth2_client = {
        ENABLE_AUTO_REGISTRATION = true;
        ACCOUNT_LINKING = "login";
      };
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

  systemd.services.forgejo-oidc-setup = {
    requires = [ "forgejo.service" ];
    after = [ "forgejo.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "forgejo";
      Group = "forgejo";
      WorkingDirectory = "/var/lib/forgejo";
      Environment = [
        "HOME=/var/lib/forgejo"
        "FORGEJO_WORK_DIR=/var/lib/forgejo"
        "FORGEJO_CUSTOM=/var/lib/forgejo/custom"
      ];
      LoadCredential = [
        "forgejo-oidc:${config.age.secrets.forgejo-oidc.path}"
      ];
    };
    script = ''
      # Best-effort wait: Authelia restarts on config changes, and its OIDC
      # discovery may 502 briefly. The DB write below does not strictly
      # require Authelia to be up (creation only parses the discovery URL),
      # so proceed after the wait regardless.
      for i in $(seq 1 30); do
        if ${pkgs.curl}/bin/curl -fsS --max-time 5 "https://authelia.home.debling.com.br/.well-known/openid-configuration" >/dev/null; then
          break
        fi
        sleep 2
      done
      # NOTE: rotating secrets/forgejo-oidc.age also requires
      # `systemctl restart forgejo-oidc-setup` to push the secret into Forgejo's DB.
      secret="$(tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/forgejo-oidc")"
      bin="${config.services.forgejo.package}/bin/forgejo"
      set_args() {
        "$bin" admin auth "$@" \
          --name authelia \
          --provider openidConnect \
          --key forgejo \
          --secret "$secret" \
          --auto-discover-url "https://authelia.home.debling.com.br/.well-known/openid-configuration" \
          --scopes openid \
          --scopes profile \
          --scopes email \
          --scopes groups \
          --group-claim-name groups \
          --admin-group admins
      }
      auth_id=""
      while read -r rid rname _rest; do
        if [ "$rname" = "authelia" ]; then auth_id="$rid"; fi
      done < <("$bin" admin auth list)
      if [ -n "$auth_id" ]; then
        set_args update-oauth --id "$auth_id"
      else
        set_args add-oauth
      fi
    '';
  };
}
