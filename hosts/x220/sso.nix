{
  config,
  ...
}:

let
  portalDomain = "authelia.home.debling.com.br";
in
{
  # NOTE:
  # The Jellyfin SSO plugin deployment moved to modules/nixos/jellyfin-sso.nix
  # (host-agnostic — Jellyfin itself moved to ryzen, reverse-proxied by the
  # x220 nginx). The "jellyfin" OIDC *client* registration further below
  # stays: the public URL https://jellyfin.home.debling.com.br is unchanged.

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

      storage = {
        postgres = {
          address = "tcp://127.0.0.1:5432";
          database = "authelia";
          username = "authelia";
          password = "";
        };
      };

      telemetry.metrics = {
        enabled = true;
        address = "tcp://127.0.0.1:9959";
      };

      session.cookies = [
        {
          domain = "home.debling.com.br";
          authelia_url = "https://${portalDomain}";
        }
      ];

      access_control = {
        default_policy = "deny";

        rules = [
          # NOTE: seerr is intentionally absent — it is served by a plain local
          # proxy (hosts/x220/arr.nix) because it has no OIDC/forward-auth
          # support upstream, so the Authelia barrier would double-login.
          {
            domain = [
              "paperless.home.debling.com.br"
              "sonarr.home.debling.com.br"
              "radarr.home.debling.com.br"
              "lidarr.home.debling.com.br"
              "prowlarr.home.debling.com.br"
              "bazarr.home.debling.com.br"
              "transmission.home.debling.com.br"
              "tdarr.home.debling.com.br"
            ];
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
        {
          client_id = "jellyfin";
          client_name = "Jellyfin";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$tLhfFmduBfw9WQvA7RhqHQ$9ZOIQuZfpSs4fQybHc5RJdNAr1s7CB+7Um/m48oru7w";
          redirect_uris = [
            "https://jellyfin.home.debling.com.br/sso/OID/redirect/authelia"
          ];
          scopes = [
            "openid"
            "profile"
            "groups"
          ];
          require_pkce = true;
          pkce_challenge_method = "S256";
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          access_token_signed_response_alg = "none";
          userinfo_signed_response_alg = "none";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          client_id = "penpot";
          client_name = "Penpot";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$n7mgdpTjjDFLbdP307uZRQ$NfJvQiPfQtlSZE55KSARcU2Hi+AGnzcaTgqAMKO3+ZA";
          redirect_uris = [
            "https://penpot.home.debling.com.br/api/auth/oidc/callback"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          token_endpoint_auth_method = "client_secret_post";
          claims_policy = "penpot";
        }
        {
          client_id = "nextcloud";
          client_name = "Nextcloud";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$LYtbawZRz5M472f8GuzkMA$TjM8fCL9S4gvQku4+yFUIpWTxMUmD6pu7UCKWooqSaU";
          redirect_uris = [
            "https://nextcloud.home.debling.com.br/apps/user_oidc/code"
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
          claims_policy = "nextcloud";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          client_id = "forgejo";
          client_name = "Forgejo";
          client_secret = "$argon2id$v=19$m=65536,t=3,p=4$C82dlSeg7MrcUCjs95/kAg$1HUVHiIijdK0Sa33uaNHJPuKj8nk0WzkFzRjL+LLr/Q";
          redirect_uris = [
            "https://forgejo.home.debling.com.br/user/oauth2/authelia/callback"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          # NOTE: no require_pkce on purpose — Forgejo as OIDC *client*
          # sends no code_challenge (unlike paperless/nextcloud), so
          # requiring it would break login. client_secret_post matches
          # this repo's other confidential clients (live-verified working).
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          claims_policy = "forgejo";
          token_endpoint_auth_method = "client_secret_post";
        }
        {
          client_id = "home-assistant";
          client_name = "Home Assistant";
          public = true;
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://assistant.home.debling.com.br/auth/oidc/callback"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
            "groups"
          ];
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          claims_policy = "home-assistant";
        }
      ];

      identity_providers.oidc.claims_policies.home-assistant.id_token = [
        "groups"
        "email"
        "name"
        "preferred_username"
      ];

      identity_providers.oidc.claims_policies.nextcloud.id_token = [
        "email"
        "email_verified"
        "name"
        "preferred_username"
        "groups"
      ];

      identity_providers.oidc.claims_policies.penpot.id_token = [
        "email"
        "email_verified"
        "name"
        "preferred_username"
      ];

      identity_providers.oidc.claims_policies.grafana.id_token = [
        "email"
        "name"
        "groups"
        "preferred_username"
      ];

      identity_providers.oidc.claims_policies.jellyfin.id_token = [
        "groups"
        "preferred_username"
        "email"
        "name"
      ];

      identity_providers.oidc.claims_policies.forgejo.id_token = [
        "groups"
        "preferred_username"
        "email"
        "name"
      ];
    };
  };

  age.secrets.nextcloud-oidc.file = ../../secrets/nextcloud-oidc.age;

#  systemd.services.nextcloud-oidc-setup = {
#    requires = [ "nextcloud-setup.service" ];
#    after = [ "nextcloud-setup.service" ];
#    wantedBy = [ "multi-user.target" ];
#    serviceConfig = {
#      Type = "oneshot";
#      RemainAfterExit = true;
#      User = "nextcloud";
#      LoadCredential = [
#        "nextcloud-oidc:${config.age.secrets.nextcloud-oidc.path}"
#      ];
#    };
#    script = ''
#      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:system:set allow_local_remote_servers --value=true --type=boolean
#      ${config.services.nextcloud.occ}/bin/nextcloud-occ user_oidc:provider authelia \
#        --clientid="nextcloud" \
#        --clientsecret-file="$CREDENTIALS_DIRECTORY/nextcloud-oidc" \
#        --discoveryuri="https://authelia.home.debling.com.br/.well-known/openid-configuration" \
#        --scope="openid profile email groups" \
#        --mapping-uid="preferred_username" \
#        --mapping-display-name="name" \
#        --mapping-email="email" \
#        --unique-uid=0 \
#        --check-bearer=0
#      echo yes | ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set --value 0 --lazy user_oidc allow_multiple_user_backends
#    '';
#  };
}
