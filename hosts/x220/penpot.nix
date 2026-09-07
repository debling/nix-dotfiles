{
  config,
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
    ];
    admins = [ "denilson@debling.com.br" ];

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
}
