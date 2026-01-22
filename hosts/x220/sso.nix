{ config, pkgs, ... }:

{
  services.nginx.virtualHosts."authelia.home.debling.com.br" = {
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

    secrets =
      let
        jwtSecretFile = pkgs.writeText "authelia-jwt-secret" "CHANGE_ME_SUPER_RANDOM_JWT_SECRET";
        storageKeyFile = pkgs.writeText "authelia-storage-key" "CHANGE_ME_32+_BYTE_RANDOM_KEY";
      in
      {
        jwtSecretFile = jwtSecretFile;
        storageEncryptionKeyFile = storageKeyFile;
      };

    settings = {
      server = {
        address = "tcp://127.0.0.1:9991";
      };

      log.level = "info";

      authentication_backend = {
        ldap = {
          url = "ldaps://home.debling.com.br";
          base_dn = "dc=home,dc=debling,dc=com,br";
          username_attribute = "cn";
          additional_users_dn = "";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          additional_groups_dn = "";
          groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
          group_name_attribute = "cn";
          mail_attribute = "mail";
          display_name_attribute = "displayName";
          user = "cn=admin,dc=home,dc=debling,dc=com,br";
          password = "test";
        };
      };

      storage = {
        postgres = {
          address = "tcp://127.0.0.1:5432";
          database = "authelia";
          username = "authelia";
          password = "STRONG_PASSWORD";
        };
      };

      session = {
        name = "authelia_session";
        secret = "SESSION_SECRET";
        expiration = "1h";
        inactivity = "5m";
        domain = "home.debling.com.br";
      };

      access_control = {
        default_policy = "deny";

        rules = [
          {
            domain = "*.home.debling.com.br";
            policy = "one_factor";
          }
        ];
      };

      notifier = {
        filesystem = {
          filename = "/tmp/authelia/notification.txt";
        };
      };
    };
  };

}
