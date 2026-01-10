{config, pkgs, ...}:

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

environment.etc."authelia/users.yml" = {
  mode = "0400";
  user = "authelia-main";
  group = "authelia-main";

  text = ''
users:
  debling:
    displayname: "Denílson"
    password: "$argon2id$v=19$m=65536,t=3,p=4$pwgLJm/K+XA0d7hkyq86gw$31VLdNuc8mua2C5wzJj3rAcMt0shyEEW4VqG+XVBqXo"
    email: denilson@home.debling.com.br
    groups:
      - grafana-admin
'';
};


services.authelia.instances.main = {
    enable = true;

    secrets = let
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
        file = {
          path = "/etc/authelia/users.yml";
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
