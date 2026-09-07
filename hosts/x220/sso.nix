{
  config,
  pkgs,
  ...
}:
let
  portalDomain = "authelia.home.debling.com.br";
in
{
  age.secrets.authelia-jwt = {
    file = ../../secrets/authelia-jwt.age;
    owner = "authelia-main";
    group = "authelia-main";
  };
  age.secrets.authelia-storage-key = {
    file = ../../secrets/authelia-storage-key.age;
    owner = "authelia-main";
    group = "authelia-main";
  };
  age.secrets.authelia-session-secret = {
    file = ../../secrets/authelia-session-secret.age;
    owner = "authelia-main";
    group = "authelia-main";
  };
  age.secrets.authelia-oidc-hmac = {
    file = ../../secrets/authelia-oidc-hmac.age;
    owner = "authelia-main";
    group = "authelia-main";
  };
  age.secrets.authelia-oidc-jwks = {
    file = ../../secrets/authelia-oidc-jwks.age;
    owner = "authelia-main";
    group = "authelia-main";
  };

  services.nginx.virtualHosts.${portalDomain} = {
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";

    locations."/" = {
      proxyPass = "http://127.0.0.1:9991";
      proxyWebsockets = true;
    };
  };

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.age.secrets.authelia-jwt.path;
      storageEncryptionKeyFile = config.age.secrets.authelia-storage-key.path;
      sessionSecretFile = config.age.secrets.authelia-session-secret.path;
      oidcHmacSecretFile = config.age.secrets.authelia-oidc-hmac.path;
      oidcIssuerPrivateKeyFile = config.age.secrets.authelia-oidc-jwks.path;
    };

    settings = {
      server.address = "tcp://127.0.0.1:9991";
      log.level = "info";

      authentication_backend.file.path = ./authelia-users.yaml;

      storage.local.path = "/var/lib/authelia-main/storage.sqlite3";

      session.cookies = [
        {
          domain = "home.debling.com.br";
          authelia_url = "https://${portalDomain}";
        }
      ];

      access_control = {
        default_policy = "deny";

        rules = [
          {
            domain = "paperless.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "sonarr.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "radarr.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "lidarr.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "prowlarr.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "bazarr.home.debling.com.br";
            policy = "one_factor";
          }
          {
            domain = "seerr.home.debling.com.br";
            policy = "one_factor";
          }
        ];
      };

      notifier.filesystem.filename = "/var/lib/authelia-main/notification.txt";

      identity_providers.oidc.clients = [
        {
          client_id = "paperless";
          client_name = "Paperless";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$21Nt3JOB5tHvFSS//l2bCw$elVYh9fo8anVQU8kLA158XbwW4dl3TAg6fhIdUr9ePc";
          redirect_uris = [
            "https://paperless.home.debling.com.br/accounts/oidc/authelia/login/callback/"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          require_pkce = true;
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          client_id = "grafana";
          client_name = "Grafana";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$OKZO+OHeWy7uKlsYtZcj4w$C8QQgmxNZ9YGBUeEV8RLCuX72l6BBumL1kHcXCl6idA";
          redirect_uris = [
            "https://grafana.home.debling.com.br/login/generic_oauth"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          require_pkce = true;
          pkce_challenge_method = "S256";
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          claims_policy = "grafana";
        }
      ];

      identity_providers.oidc.claims_policies.grafana.id_token = [
        "email"
        "name"
        "groups"
        "preferred_username"
      ];
    };
  };
}
