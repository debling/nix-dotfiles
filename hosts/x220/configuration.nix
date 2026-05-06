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
  myIp = "10.0.10.1";
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
in
{
  imports = [
    ../../modules/nixos/prelude.nix
    ../../modules/nixos/users.nix
    ../../modules/common/containers.nix
    ../../modules/common/nix.nix
    ../../modules/nixos/glauth.nix
    ./arr.nix
    #./samba.nix
    # ./sso.nix
    ../../modules/nixos/home-assistant.nix
    ./speedtest.nix
    ./observability.nix
    ./networking.nix
  ];

  documentation.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  documentation.doc.enable = false;
  hardware.facter.reportPath = ./facter.json;

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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
  ];

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

  /*
    secret on /etc/secrets/hostinger like:
        HOSTINGER_API_TOKEN=<hostinger api key>
        HOSTINGER_PROPAGATION_TIMEOUT=300
        HOSTINGER_POLLING_INTERVAL=30
  */
  age.secrets.acme_hostinger.file = ../../secrets/acme_hostinger.age;
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "d.ebling8@gmail.com";
    };
    certs."home.debling.com.br" = {
      dnsProvider = "hostinger";
      environmentFile = config.age.secrets.acme_hostinger.path;
      extraDomainNames = [ "*.home.debling.com.br" ];
      group = config.services.nginx.group;
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    virtualHosts.${myIp}.locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8096"; # jellyfin
      };

      "/blocky/" = {
        proxyPass = "http://127.0.0.1:4000/";
      };
    };
    virtualHosts."assistant.home.debling.com.br" = makeNginxLocalProxy 8123;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    extensions = ps: [ ps.postgis ];
    ensureDatabases = [
      "grafana"
      "nextcloud"
      "blocky"
      "authelia"
      "radarr"
      "bazarr"
      "sonarr"
      "lidarr"
      "prowlarr"
      "readarr"
      "dhcp"
    ];
    ensureUsers = [
      {
        name = "readarr";
        ensureDBOwnership = true;
      }
      {
        name = "prowlarr";
        ensureDBOwnership = true;
      }
      {
        name = "radarr";
        ensureDBOwnership = true;
      }
      {
        name = "bazarr";
        ensureDBOwnership = true;
      }
      {
        name = "sonarr";
        ensureDBOwnership = true;
      }
      {
        name = "lidarr";
        ensureDBOwnership = true;
      }
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
      {
        name = "dhcp";
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

  # systemd.services.dhcp-db-init = {
  #   requires = [ "postgresql.service" ];
  #   after = [ "postgresql.service" ];
  #   wantedBy = [ "multi-user.target" ];
  #   path = [ config.services.postgresql.package ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "dhcp";
  #     ExecStart = "${config.services.postgresql.package}/bin/psql -d dhcp -f ${./dhcp-schema.sql}";
  #     RemainAfterExit = true;
  #   };
  # };

  # systemd.services.dnsmasq = {
  #   requires = [ "dhcp-db-init.service" ];
  #   after = [ "dhcp-db-init.service" ];
  # };

  services.glauth = {
    enable = false;
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

    package = pkgs.nextcloud33;
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

          {
            HomeAssistant = {
              href = "https://assistant.home.debling.com.br";
              icon = "home-assistant";
            };
          }

        ];
      }
    ];
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };
}
