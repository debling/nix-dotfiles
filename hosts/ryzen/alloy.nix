{ ... }:

{
  services.alloy = {
    enable = true;
  };

  environment.etc."alloy/config.alloy".text = /* hcl */ ''
    prometheus.remote_write "x220" {
      endpoint {
        url = "http://x220.home.debling.com.br:9090/api/v1/write"
      }
    }

    prometheus.exporter.unix "local" { }
    prometheus.scrape "local" {
      scrape_interval = "15s"
      targets    = prometheus.exporter.unix.local.targets
      forward_to = [prometheus.remote_write.x220.receiver]
    }
  '';
}
