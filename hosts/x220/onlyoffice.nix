{ config, ... }:

let
  jwtSecretFile = "/etc/onlyoffice-jwt-secret";
  securityNonceFile = "/etc/onlyoffice-nonce.conf";
in
{
  services.onlyoffice = {
    enable = true;
    hostname = "office.home.debling.com.br";
    port = 8000;
    #jwtSecretFile = jwtSecretFile;
    securityNonceFile = securityNonceFile;
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

  environment.etc."onlyoffice-jwt-secret".text = "changeme-use-strong-random-secret";
  environment.etc."onlyoffice-nonce.conf".text = ''set $secure_link_secret "changeme";'';

  # systemd.services.nextcloud-onlyoffice-setup = {
  #   requires = [ "nextcloud-setup.service" "onlyoffice-docservice.service" ];
  #   after = [ "nextcloud-setup.service" "onlyoffice-docservice.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     User = "nextcloud";
  #     Environment = [
  #       "NEXTCLOUD_CONFIG_DIR=/var/lib/nextcloud/config"
  #     ];
  #   };
  #   script = ''
  #     ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set onlyoffice DocumentServerUrl --value="https://office.home.debling.com.br/"
  #     ${config.services.nextcloud.occ}/bin/nextcloud-occ config:app:set onlyoffice jwt_secret --value="$(cat ${jwtSecretFile})"
  #   '';
  # };
}
