{
  config,
  lib,
  ...
}:

{
  age.secrets.onlyoffice-jwt = {
    file = ../../secrets/onlyoffice-jwt.age;
    group = "onlyoffice";
    mode = "0440";
  };
  age.secrets.onlyoffice-nonce = {
    file = ../../secrets/onlyoffice-nonce.age;
    group = "onlyoffice";
    mode = "0440";
  };

  users.users.nextcloud.extraGroups = [ "onlyoffice" ];
  users.users.nginx.extraGroups = [ "onlyoffice" ];

  services.onlyoffice = {
    enable = true;
    hostname = "office.home.debling.com.br";
    port = 8000;
    jwtSecretFile = config.age.secrets.onlyoffice-jwt.path;
    securityNonceFile = config.age.secrets.onlyoffice-nonce.path;
    postgresHost = "127.0.0.1";
    postgresName = "onlyoffice";
    postgresUser = "onlyoffice";
  };

  services.epmd.listenStream = "127.0.0.1:4369";

  services.nginx.virtualHosts."office.home.debling.com.br" = {
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";
    extraConfig = "client_max_body_size 100M;";
    locations."~ ^(/[0-9]+[.][0-9]+[.][0-9]+[.|-][a-zA-Z0-9_-]+)?(/(plugins[.]json|themes[.]json))$" = {
      proxyPass = "http://onlyoffice-docservice$2";
    };
  };

  services.postgresql = {
    ensureDatabases = [ "onlyoffice" ];
    ensureUsers = [
      {
        name = "onlyoffice";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.nextcloud-onlyoffice-setup = {
    requires = [ "nextcloud-setup.service" "onlyoffice-docservice.service" ];
    after = [ "nextcloud-setup.service" "onlyoffice-docservice.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nextcloud";
      Environment = [
        "NEXTCLOUD_CONFIG_DIR=/var/lib/nextcloud/config"
      ];
    };
    script = ''
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set onlyoffice DocumentServerUrl --value="https://office.home.debling.com.br/"
      ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set onlyoffice jwt_secret --value="$(cat ${config.age.secrets.onlyoffice-jwt.path})"
    '';
  };
}
