{pkgs, ...}:

let 

  makeNginxLocalProxy = port: {
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}";
      proxyWebsockets = true;
    };
  };

in
    {

    services.nginx.virtualHosts."assistant.home.debling.com.br" = makeNginxLocalProxy 8123;
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraPackages = python3packages: with python3packages; [
      gtts
      zlib-ng
      isal
      caldav
            python-otbr-api
            pychromecast
            radios
    ];
    extraComponents = [
      "default_config"
      "esphome"
      "tile"
      "matter"
      "moon"
      "sun"
      "zha"
      "zone"
      "mobile_app"
      "met"
      "isal"
      "tuya"
      "tplink"
    ];
    config = {
            mobile_app = {};

      http = {
        server_host = [
          "127.0.0.1"
        ];
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        server_port = 8123;

      };
      homeassistant = {
        unit_system = "metric";
        latitude = 29.6895;
        longitude = 53.7923;
      };
    };
  };
}
