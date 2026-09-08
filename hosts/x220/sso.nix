{
  config,
  lib,
  pkgs,
  ...
}:
let
  portalDomain = "authelia.home.debling.com.br";
in
{
  age.secrets.jellyfin-sso.file = ../../secrets/jellyfin-sso.age;

  systemd.services.jellyfin = {
    serviceConfig.EnvironmentFile = config.age.secrets.jellyfin-sso.path;

    preStart =
      let
        plugin = pkgs.stdenv.mkDerivation {
          pname = "jellyfin-plugin-sso";
          version = "4.3.0.61";
          src = pkgs.fetchurl {
            url = "https://github.com/Flowfin/jellyfin-plugin-sso/releases/download/4.3.0-beta.61/community-sso-for-jellyfin_4.3.0.61.zip";
            hash = "sha256-h7JkOorDHq01Yt/Am7q8K7gulvJJsTh/FcSxskmYoKo=";
          };
          nativeBuildInputs = [ pkgs.unzip ];
          buildCommand = ''
            mkdir -p $out
            unzip -q $src -d $out
          '';
        };
        pluginConfig = pkgs.writeText "SSO-Auth-template.xml" ''
          <?xml version="1.0" encoding="utf-8"?>
          <PluginConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <SamlConfigs />
            <OidConfigs>
              <item>
                <key>
                  <string>authelia</string>
                </key>
                <value>
                  <PluginConfiguration>
                    <OidEndpoint>https://authelia.home.debling.com.br</OidEndpoint>
                    <OidClientId>jellyfin</OidClientId>
                    <OidSecret>@OID_SECRET@</OidSecret>
                    <Enabled>true</Enabled>
                    <EnableAuthorization>true</EnableAuthorization>
                    <EnableAllFolders>true</EnableAllFolders>
                    <EnabledFolders />
                    <AllowExistingAccountLink>true</AllowExistingAccountLink>
                    <AdminRoles>
                      <string>admins</string>
                    </AdminRoles>
                    <Roles>
                      <string>admins</string>
                    </Roles>
                    <EnableFolderRoles>false</EnableFolderRoles>
                    <EnableLiveTvRoles>false</EnableLiveTvRoles>
                    <EnableLiveTv>false</EnableLiveTv>
                    <EnableLiveTvManagement>false</EnableLiveTvManagement>
                    <LiveTvRoles />
                    <LiveTvManagementRoles />
                    <FolderRoleMappings />
                    <RoleClaim>groups</RoleClaim>
                    <OidScopes>
                      <string>groups</string>
                    </OidScopes>
                    <CanonicalLinks />
                    <DisableHttps>false</DisableHttps>
                    <DoNotValidateEndpoints>false</DoNotValidateEndpoints>
                    <DoNotValidateIssuerName>false</DoNotValidateIssuerName>
                    <AllowPrivateNetworkAddresses>true</AllowPrivateNetworkAddresses>
                    <DisablePushedAuthorization>true</DisablePushedAuthorization>
                    <SchemeOverride>https</SchemeOverride>
                  </PluginConfiguration>
                </value>
              </item>
            </OidConfigs>
            <ProvisioningProfiles />
            <EnableRateLimit>false</EnableRateLimit>
            <RateLimitMaxAttempts>30</RateLimitMaxAttempts>
            <RateLimitWindowSeconds>60</RateLimitWindowSeconds>
            <ManageLoginPageButtons>true</ManageLoginPageButtons>
            <EnableSingleLogout>false</EnableSingleLogout>
            <DisablePasswordLogin>false</DisablePasswordLogin>
            <SsoOnlyRepointedUserIds />
            <LogoutSessions />
          </PluginConfiguration>
        '';
        jellyfinDataDir = config.services.jellyfin.dataDir;
      in
      ''
        install -d "${jellyfinDataDir}/plugins/SSO-Auth_4.3.0.61"
        cp -rf ${plugin}/. "${jellyfinDataDir}/plugins/SSO-Auth_4.3.0.61/"
        chmod -R u+w "${jellyfinDataDir}/plugins/SSO-Auth_4.3.0.61/"
        install -d "${jellyfinDataDir}/plugins/configurations"
        sed "s|@OID_SECRET@|$JELLYFIN_OID_SECRET|" ${pluginConfig} > "${jellyfinDataDir}/plugins/configurations/SSO-Auth.xml"
      '';
  };
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
          {
            domain = [
              "paperless.home.debling.com.br"
              "sonarr.home.debling.com.br"
              "radarr.home.debling.com.br"
              "lidarr.home.debling.com.br"
              "prowlarr.home.debling.com.br"
              "bazarr.home.debling.com.br"
              "seerr.home.debling.com.br"
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
          authorization_policy = "one_factor";
          consent_mode = "implicit";
          claims_policy = "nextcloud";
          token_endpoint_auth_method = "client_secret_post";
        }
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
    };
  };

  age.secrets.nextcloud-oidc.file = ../../secrets/nextcloud-oidc.age;

  systemd.services.nextcloud-oidc-setup = {
    requires = [ "nextcloud-setup.service" ];
    after = [ "nextcloud-setup.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
      LoadCredential = [
        "nextcloud-oidc:${config.age.secrets.nextcloud-oidc.path}"
      ];
    };
    script = ''
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:system:set allow_local_remote_servers --value=true --type=boolean
      ${config.services.nextcloud.occ}/bin/nextcloud-occ user_oidc:provider authelia \
        --clientid="nextcloud" \
        --clientsecret-file="$CREDENTIALS_DIRECTORY/nextcloud-oidc" \
        --discoveryuri="https://authelia.home.debling.com.br/.well-known/openid-configuration" \
        --scope="openid profile email" \
        --mapping-uid="preferred_username" \
        --mapping-display-name="name" \
        --mapping-email="email" \
        --unique-uid=0 \
        --check-bearer=0
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set user_oidc allow_multiple_user_backends --value 0
    '';
  };
}
