{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.penpot = {
    enable = true;
    publicUri = "https://penpot.home.debling.com.br";
    secretKeyFile = config.age.secrets.penpot-secret-key.path;

    # prepl is required for `penpot-manage`; accounts are CLI-created only.
    flags = [
      "enable-prepl-server"
      "disable-registration"
      "disable-email-verification"
      "enable-login-with-oidc"
    ];
    admins = [ "denilson@debling.com.br" ];

    oidc.name = "Authelia";

    environment = {
      PENPOT_OIDC_CLIENT_ID = "penpot";
      PENPOT_OIDC_BASE_URI = "https://authelia.home.debling.com.br";
      PENPOT_SSRF_ALLOWED_HOSTS = "authelia.home.debling.com.br";
    };

    jvmOpts = [
      "-Xms256m"
      "-Xmx1g"
    ];

    nginx.forceHttps = true;
    exporter.internalUri = "https://penpot.home.debling.com.br";
  };

  services.nginx.virtualHosts."penpot.home.debling.com.br" = {
    useACMEHost = "home.debling.com.br";
  };

  age.secrets.penpot-secret-key.file = ../../secrets/penpot-secret-key.age;
  age.secrets.penpot-oidc = {
    file = ../../secrets/penpot-oidc.age;
    owner = "penpot";
    group = "penpot";
    mode = "0440";
  };

  systemd.services.penpot-env = {
    serviceConfig.LoadCredential = [
      "penpot-oidc:${config.age.secrets.penpot-oidc.path}"
    ];
    serviceConfig.ExecStartPost = [
      (pkgs.writeShellScript "penpot-oidc-secret" ''
        echo "PENPOT_OIDC_CLIENT_SECRET=$(cat "$CREDENTIALS_DIRECTORY/penpot-oidc" | tr -d '\r\n')" >> /run/penpot/env
      '')
    ];
  };
}
