# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  mainUser,
  ...
}:

let
  myDomain = "x220";
  myIp = "192.168.0.254";
  makeNginxLocalProxy = port: ({
    forceSSL = true;
    http3 = true;
    quic = true;
    useACMEHost = "home.debling.com.br";
    locations."/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}";
      proxyWebsockets = true;
    };
  });
in
{
  imports = [
    ../../modules/common/containers.nix
    ../../modules/common/nix.nix
    ../../modules/nixos/glauth.nix
    ./arr.nix
    ./samba.nix
    # ./sso.nix
    ../../modules/nixos/home-assistant.nix
  ];

  powerManagement.powertop.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernel.sysctl."vm.swappiness" = 200;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  zramSwap = {
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${mainUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "podman" # docker and podman without sudo
    ];
    hashedPassword = "$y$j9T$O4qn0aOF8U9FQPiMXsv41/$CkOtnJbkV4lcZcCwQnUL0u4xlfoYhvN.9pCUzT2uFI5";
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
  ];

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services = {
    fstrim.enable = true;
    tlp.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # uxplay
      tmux
      wget
      git
      gnumake
      htop
      ncdu
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs = {
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    neovim.enable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  services.openssh.enable = true;
  networking = {
    useNetworkd = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        80
        443
        53
        22
      ];
      allowedUDPPorts = [ 53 ];
    };
    hostName = "x220";
    useDHCP = false;
    enableIPv6 = false;
    interfaces.enp0s25 = {
      ipv4.addresses = [
        {
          address = myIp;
          prefixLength = 24;
        }
      ];
      useDHCP = false;
      wakeOnLan.enable = true;
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp0s25";
    };
    nameservers = [ "127.0.0.1" ];
  };

  /*
    secret on /etc/secrets/hostinger like:
        HOSTINGER_API_TOKEN=<hostinger api key>
        HOSTINGER_PROPAGATION_TIMEOUT=300
        HOSTINGER_POLLING_INTERVAL=30
  */
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "d.ebling8@gmail.com";
    };
    certs."home.debling.com.br" = {
      dnsProvider = "hostinger";
      credentialsFile = "/etc/secrets/hostinger";
      extraDomainNames = [ "*.home.debling.com.br" ];
      group = config.services.nginx.group;
    };
  };

  services.resolved.settings.Resolve.DNSStubListener = "no"; # Disable the resolved dns server on port
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    virtualHosts.${myIp}.locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8082"; # homepage
      };

      "/blocky/" = {
        proxyPass = "http://127.0.0.1:4000/";
      };
    };
    virtualHosts."assistant.home.debling.com.br" = makeNginxLocalProxy 8123;
  };

  services.blocky = {
    enable = true;
    settings = {
      ports.http = 4000;
      upstreams.groups.default = [
        "https://dns.quad9.net/dns-query"
        "https://dns.adguard-dns.com"
        "https://1.1.1.1/dns-query"
        "tcp-tls:1.1.1.1:853"
        # "tcp-tls://dns.adguard-dns.com"
      ];
      bootstrapDns = "9.9.9.9";

      customDNS = {
        customTTL = "1h";
        mapping = {
          "home.debling.com.br" = "${myIp},100.83.30.120";
          "router.arpa" = "192.168.0.1";
        };
      };
      prometheus.enable = true;
      caching.prefetching = true;
      blocking = {
        denylists.ads = [
          "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/ultimate.txt"
          "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
          "https://mirror1.malwaredomains.com/files/justdomains"
          "http://sysctl.org/cameleon/hosts"
          "https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist"
          "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
        ];
        clientGroupsBlock.default = [ "ads" ];
        blockType = "zeroIp";
      };
      queryLog = {
        type = "postgresql";
        target = "postgres://blocky@localhost:5432/blocky";
        logRetentionDays = 90;
      };
      clientLookup = {
        upstream = "192.168.0.1";
        singleNameOrder = [ 1 ];
      };

      # dnssec.validate = true;
    };
  };

  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
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
        static_configs = [
          { targets = [ "localhost:9100" ]; }
        ];
      }
    ];
  };

  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} =
    makeNginxLocalProxy 3000;
  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];
    settings = {
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
      ];

      dashboards.settings.providers = [
        {
          name = "Nix config dashboards";
          type = "file";
          options =
            let
              blockyQueryDashboardRaw = pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/0xERR0R/blocky/refs/heads/main/docs/blocky-query-grafana-postgres.json";
                sha256 = "sha256-j/YHpgly0qFj+hE2XzRXx04HOM3GxSvKVI6UNMq7Vtk=";
              };
              configuredBlockyQueryDashboard = pkgs.writeText "blocky-query-grafana-postgres.json" (
                builtins.replaceStrings [ "\${DS_POSTGRES}" ] [ "Blocky PostgreSQL" ] (
                  builtins.readFile blockyQueryDashboardRaw
                )
              );

              blockyDashboard = pkgs.fetchurl {
                url = "https://0xerr0r.github.io/blocky/latest/blocky-grafana.json";
                sha256 = "sha256-InIKXAmovhDfYqBFGDNk/Cyj0hQQVjTuyDdTumV2yOg=";
              };
              nodeDashboard = pkgs.fetchurl {
                url = "https://grafana.com/api/dashboards/1860/revisions/42/download";
                sha256 = "sha256-pNgn6xgZBEu6LW0lc0cXX2gRkQ8lg/rer34SPE3yEl4=";
              };
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
              ];
            in
            {
              path = dashboardDir;
            };
        }
      ];
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "grafana"
      "nextcloud"
      "blocky"
      "authelia"
    ];
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "blocky";
        ensureDBOwnership = true;
      }
      {
        name = "authelia";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
    '';
  };

  services.glauth = {
    enable = true;
    group = "nginx";
    settings = {
      ldaps = {
        enabled = true;
        listen = "0.0.0.0:636";
        cert = "/var/lib/acme/home.debling.com.br/fullchain.pem";
        key = "/var/lib/acme/home.debling.com.br/key.pem";
      };
      backend = {
        datastore = "config";
        baseDN = "dc=home,dc=debling,dc=com,br";
      };
      users = [
        {
          name = "admin";
          uidnumber = 999;
          primarygroup = 999;
          password = "test";
        }
        {
          name = "debling";
          uidnumber = 1000;
          primarygroup = 1000;
          mail = "denilson@debling.com.br";
          givenname = "Denílson";
          sn = "Ebling";
          passbcrypt = "$2b$05$lqmU9.4FFEnbpkO9i0/QYO/gKBJlp46QPQJlTBrXWpkaK12I.ep8u";
        }
        {
          name = "vivianedn";
          uidnumber = 1001;
          primarygroup = 1000;
          mail = "viviane@debling.com.br";
          givenname = "Viviane";
          sn = "DN";
          passbcrypt = "$2b$05$lqmU9.4FFEnbpkO9i0/QYO/gKBJlp46QPQJlTBrXWpkaK12I.ep8u";
        }
      ];
      groups = [
        {
          name = "admin";
          gidnumber = 999;
          members = [ "admin" ];
        }
        {
          name = "debling";
          gidnumber = 1000;
          members = [ "debling" ];
        }
        {
          name = "vivianedn";
          gidnumber = 1001;
          members = [ "vivianedn" ];
        }
      ];
      behaviors = {
        allowlocalanonymous = true;
      };
    };
  };

  services.nginx.virtualHosts."nextcloud.home.debling.com.br" = {
    forceSSL = true;
    useACMEHost = "home.debling.com.br";
  };
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.home.debling.com.br";
    https = true;
    configureRedis = true;
    config = {
      dbtype = "pgsql";
      dbhost = "localhost";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      adminpassFile = "/etc/nextcloud-admin-pass";
      adminuser = "admin";
    };
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps)
        news
        contacts
        calendar
        tasks
        mail
        forms
        tables
        whiteboard
        onlyoffice
        notes
        ;
    };
    extraAppsEnable = true;

    package = pkgs.nextcloud32;
  };

  environment.etc."nextcloud-admin-pass".text = "changeme";

  services.nginx.virtualHosts."home.debling.com.br" = makeNginxLocalProxy 8082;
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "${myDomain},${myIp},home.debling.com.br,x220,x220.fable-ph.ts.net";

    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    # Example of linking services (Grafana, Blocky UI, etc.)
    services = [
      {
        Geral = [
          {
            Grafana = {
              href = "https://grafana.home.debling.com.br";
              icon = "grafana";
            };
          }

          {
            Blocky = {
              href = "https://blocky.home.debling.com.br"; # Blocky WebUI or metrics
              icon = "blocky";
            };
          }

          {
            Nextcloud = {
              href = "https://nextcloud.home.debling.com.br";
              icon = "nextcloud";
            };
          }

        ];
      }
    ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
