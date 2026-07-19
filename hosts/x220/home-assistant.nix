{ pkgs, serverUtils, ... }:

{
  services.nginx.virtualHosts."assistant.home.debling.com.br" = serverUtils.makeNginxLocalProxy 8123;
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "default_config"
      "mobile_app"
      "tuya"
      "cast"
      "tplink"
      "jellyfin"
      "lg_netcast"
      "transmission"
      "spotify"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [ localtuya ];
    config = {
      mobile_app = { };

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
