{ pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers.speedtest-exporter = {
    image = "ghcr.io/miguelndecarvalho/speedtest-exporter:latest";
    extraOptions = [ "--network=host" ];
  };

  services.prometheus.scrapeConfigs = lib.mkAfter [
    {
      job_name = "speedtest";
      scrape_interval = "15m";
      scrape_timeout = "1m";
      static_configs = [ { targets = [ "localhost:9798" ]; } ];
    }
  ];

  services.grafana.provision.dashboards.settings.providers = lib.mkAfter [
    {
      name = "Speedtest dashboards";
      type = "file";
      options.path =
        let
          speedtestDashboardRaw = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/MiguelNdeCarvalho/speedtest-exporter/main/Dashboard/Speedtest-Exporter.json";
            sha256 = "sha256-c65KoFFSfTIIPnRmXML348z6C8/4U6BPvV2fLy6wO5U=";
          };
          configuredSpeedtestDashboard = pkgs.writeText "speedtest-exporter.json" (
            builtins.replaceStrings [ "\${DS_PROMETHEUS}" ] [ "Prometheus" ] (
              builtins.readFile speedtestDashboardRaw
            )
          );
        in
        configuredSpeedtestDashboard;
    }
  ];
}
