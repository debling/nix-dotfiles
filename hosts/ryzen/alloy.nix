{ ... }:

{
  services.alloy = {
    enable = true;
    extraFlags = [
      "--server.http.listen-addr=127.0.0.1:12345"
    ];
  };

  environment.etc."alloy/config.alloy".text =  /* hcl */ ''
    prometheus.remote_write "x220" {
      endpoint {
        url = "http://x220:9090/api/v1/write"
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
