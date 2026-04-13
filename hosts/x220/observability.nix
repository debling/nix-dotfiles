{config, pkgs, ...}:
let
  makeNginxLocalProxy = port: {
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };

  # Define ports as variables for consistency
  ports = {
    grafana = 3100;
    prometheus = 9090;
    loki = 3102;
    alloy = 3103; # Alloy's own UI
    tempo = 3104; # HTTP
    tempoGrpc = 3105; # Internal gRPC
    tempoGrpcIngest = 3106; # gRPC used to ingest data
    grafanaImageRenderer = 3107;
    alloyOTLPGrpc = 4317; # OTLP gRPC receiver
    alloyOTLPHttp = 4318; # OTLP HTTP receiver
  };

in
{

  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} =
    makeNginxLocalProxy 3000;
  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];
    settings = {
      security.secret_key = "dfda4e08b850eacfb5bcda8aa51c0b1bb0236cfeea274990880d6c90e3d3a726";
      server = {
        domain = "grafana.home.debling.com.br";
        root_url = "%(protocol)s://%(domain)s";
      };
      panels.disable_sanitize_html = true;
      database = {
        type = "postgres";
        host = "127.0.0.1:5432";
        name = "grafana";
        user = "grafana";
        password = "";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          uid = "prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
          access = "proxy";
          isDefault = true;
          editable = false;
          jsonData = {
            timeInterval = "15s";
          };
        }
        {
          name = "Blocky PostgreSQL";
          type = "postgres";
          uid = "blocky-postgresql";
          url = "localhost:5432";
          database = "blocky";
          user = "blocky";
          jsonData = {
            sslmode = "disable";
            postgresVersion = 1400;
            timescaledb = false;
          };
          editable = true;
        }

        {
          name = "Loki";
          type = "loki";
          url = "http://localhost:${toString ports.loki}";
        }
      ];

      dashboards.settings.providers = [
        {
          name = "Nix config dashboards";
          type = "file";
          options =
            let
              blockyQueryDashboardRaw = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/0xERR0R/blocky/67dababac07d292533242a34ddfa5942ea8e813d/docs/blocky-query-grafana-postgres.json";
                sha256 = "sha256-j/YHpgly0qFj+hE2XzRXx04HOM3GxSvKVI6UNMq7Vtk";
              };
              configuredBlockyQueryDashboard = pkgs.writeText "blocky-query-grafana-postgres.json" (
                builtins.replaceStrings [ "\${DS_POSTGRES}" ] [ "Blocky PostgreSQL" ] (
                  builtins.readFile blockyQueryDashboardRaw
                )
              );

              blockyDashboard = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/0xERR0R/blocky/67dababac07d292533242a34ddfa5942ea8e813d/docs/blocky-grafana.json";
                sha256 = "sha256-zsSOO41NAuDsX2erlvwzt+fwuIEYfxnzVosJjDzUztA=";
              };
              nodeDashboard = pkgs.fetchurl {
                url = "https://grafana.com/api/dashboards/1860/revisions/42/download";
                sha256 = "sha256-pNgn6xgZBEu6LW0lc0cXX2gRkQ8lg/rer34SPE3yEl4=";
              };
              postgresDashboardRaw = pkgs.fetchurl {
                url = "https://grafana.com/api/dashboards/9628/revisions/latest/download";
                sha256 = "sha256-UhusNAZbyt7fJV/DhFUK4FKOmnTpG0R15YO2r+nDnMc=";
              };
              configuredPostgresDashboard = pkgs.writeText "postgres-exporter.json" (
                builtins.replaceStrings [ "\${DS_PROMETHEUS}" ] [ "Prometheus" ] (
                  builtins.readFile postgresDashboardRaw
                )
              );
              dashboardDir = pkgs.linkFarm "grafana-dashboards" [
                {
                  name = "blocky-query-grafana-postgres.json";
                  path = configuredBlockyQueryDashboard;
                }
                {
                  name = "blocky-grafana.json";
                  path = blockyDashboard;
                }
                {
                  name = "node-exporter.json";
                  path = nodeDashboard;
                }
                {
                  name = "postgres-exporter.json";
                  path = configuredPostgresDashboard;
                }
              ];
            in
            {
              path = dashboardDir;
            };
        }
      ];
    };
  };

  services.prometheus = {
    enable = true;
    extraFlags = [ "--web.enable-remote-write-receiver" ];
    exporters.node.enable = true;
    exporters.postgres = {
      enable = true;
      runAsLocalSuperUser = true;
    };
    scrapeConfigs = [
      {
        job_name = "blocky";
        scrape_interval = "15s";
        static_configs = [
          { targets = [ "localhost:4000" ]; }
        ];
      }
      {
        job_name = "node";
        scrape_interval = "15s";
        static_configs = [
          { targets = [ "localhost:9100" ]; }
        ];
      }
      {
        job_name = "postgres";
        scrape_interval = "15s";
        static_configs = [
          { targets = [ "localhost:9187" ]; }
        ];
      }
    ];
  };

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_address = "127.0.0.1";
      server.http_listen_port = ports.loki;
      auth_enabled = false;
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };
      # the schema config is required for loki to work
      # https://grafana.com/docs/loki/latest/operations/storage/schema/#new-loki-installs
      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      storage_config.filesystem.directory = "/var/lib/loki/chunks";
      pattern_ingester.enabled = true;
    limits_config = {
    # Allow logs older than 1 hour (e.g., 7 days or 168h)
    reject_old_samples = false;
    # Increase the window for 'out of order' logs which often happens with CloudWatch
    creation_grace_period = "10m";
    reject_old_samples_max_age = "8760h";
    # Prevent old logs from being immediately deleted
    retention_period = "8760h"; 
    max_line_size = 1048576; 
  };

    };
  };

  services.nginx.virtualHosts."otlp.internal.zeit.com.br" = {
    enableACME = true;
    forceSSL = true;
    http2 = true;

    #extraConfig = ''
    #  auth_basic "OTLP Authentication Required";
    #  auth_basic_user_file ${config.age.secrets.otlp-htpasswd.path};
    #'';
    # basicAuthFile = config.age.secrets.otlp-htpasswd.path;
    locations."/" = {
      extraConfig = /* nginx */ ''
        if ($http_content_type = "application/grpc") {
            grpc_pass grpc://127.0.0.1:${toString ports.alloyOTLPGrpc};
        }

        proxy_pass http://127.0.0.1:${toString ports.alloyOTLPHttp};
      '';
    };
  };



  services.alloy = {
    enable = true;
    extraFlags = [ "--server.http.listen-addr=127.0.0.1:${toString ports.alloy}" "--stability.level=experimental" ];
  };

  environment.etc."alloy/config.alloy".text =  /* hcl */ ''
    livedebugging {
      enabled = true
    }

     otelcol.receiver.otlp "default" {
       grpc { endpoint = "127.0.0.1:${toString ports.alloyOTLPGrpc}" }
       http { endpoint = "127.0.0.1:${toString ports.alloyOTLPHttp}" }
       output {
         metrics = [otelcol.processor.batch.main.input]
         logs    = [otelcol.processor.batch.main.input]
         // traces  = [otelcol.processor.batch.main.input]
       }
     }

    otelcol.processor.batch "main" {
      output {
        metrics = [otelcol.exporter.prometheus.local.input]
        logs    = [otelcol.exporter.loki.local.input]
        // traces  = [otelcol.exporter.otlp.tempo.input]
      }
    }

    otelcol.exporter.prometheus "local" {
      forward_to = [prometheus.remote_write.local.receiver]
    }

    otelcol.exporter.loki "local" {
      forward_to = [loki.write.local.receiver]
    }

    otelcol.exporter.otlp "tempo" {
      client {
        endpoint = "127.0.0.1:${toString ports.tempoGrpcIngest}"
        tls { insecure = true }
      }
    }

    prometheus.remote_write "local" {
      endpoint { url = "http://127.0.0.1:${toString ports.prometheus}/api/v1/write" }
    }

    loki.write "local" {
      endpoint { url = "http://127.0.0.1:${toString ports.loki}/loki/api/v1/push" }
    }

    // prometheus.exporter.unix "x220" { }
    // prometheus.scrape "host" {
    //   scrape_interval = "15s"
    //   targets    = prometheus.exporter.unix.host.targets
    //   forward_to = [prometheus.relabel.normalize_metrics.receiver]
    // }
    // prometheus.relabel "normalize_metrics" {
    //   forward_to = [prometheus.remote_write.local.receiver]
    //   rule {
    //     source_labels = ["name"]
    //     target_label  = "service_name"
    //   }
    // }

     loki.relabel "journald_labels" {
      forward_to = []

      // Rule to rename __journal__systemd_unit to 'unit'
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "service_name"
        replacement = "$1"
        regex       = "(.+)\\.service"
      }
    }

    loki.source.journal "host" {
      max_age       = "24h0m0s"
      forward_to = [loki.write.local.receiver]
      labels     = { job = "systemd-journal" }
      relabel_rules = loki.relabel.journald_labels.rules
    }
  '';
    }
