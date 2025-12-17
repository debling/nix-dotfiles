# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, mainUser, ... }:

let
  myDomain = "x220";
  myIp = "192.168.0.254";
in

{
  imports =
    [
      ../../modules/common/containers.nix
      ../../modules/common/nix.nix
      ./arr.nix
      # ../../modules/home-assistant.nix
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

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";


  services.openssh.enable = true;
  networking = {
    useNetworkd = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 80 443 53 22 ];
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

  services.resolved.enable = false;
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts.${myIp}.locations = {
      "/" = {
        proxyPass = "http://127.0.0.1:8082"; # homepage
      };

      "/blocky/" = {
        proxyPass = "http://127.0.0.1:4000/";
      };

      "/grafana/" = {
        proxyPass = "http://127.0.0.1:3000/";
        proxyWebsockets = true;
      };

      "/sonarr" = {
        proxyPass = "http://127.0.0.1:8989";
      };

      "/prowlarr" = {
        proxyPass = "http://127.0.0.1:9696";
      };

      "/overseerr" = {
        proxyPass = "http://127.0.0.1:5055";
      };

      "/transmission" = {
        proxyPass = "http://127.0.0.1:9091";
      };

      "/jellyfin" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };

      "/lidarr" = {
        proxyPass = "http://127.0.0.1:8686";
        proxyWebsockets = true;
      };

      "/nextcloud" = {
        proxyPass = "http://127.0.0.1:8080";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 10G;
        '';
      };
    };
  };

  services.blocky = {
    enable = true;
    settings = {
      ports.http = 4000;
      upstreams.groups.default = [
        "https://dns.adguard-dns.com"
        "tcp-tls:1.1.1.1:853"
        "https://dns.quad9.net/dns-query"
        # "tcp-tls://dns.adguard-dns.com"
        "https://1.1.1.1/dns-query"
      ];

      customDNS = {
        customTTL = "1h";
        mapping = {
          "home.arpa" = myIp;
          ${myDomain} = myIp;
          "router" = "192.168.0.1";
        };
      };
      prometheus.enable = true;

      caching.prefetching = true;

      blocking = {
        denylists.ads = [
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

  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];
    settings = {
      server = {
        domain = myDomain;
        root_url = "%(protocol)s://%(domain)s/grafana";
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
          type = "prometheus";
          url = "http://localhost:9090";
          access = "proxy";
          isDefault = true;
        }
      ];
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "grafana" "nextcloud" ];
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
  };

  services.nextcloud = {
    enable = true;
    hostName = "x220";
    config = {
      dbtype = "pgsql";
      dbhost = "localhost";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      adminpassFile = "/etc/nextcloud-admin-pass";
      adminuser = "admin";
    };

    package = pkgs.nextcloud32;
  };

  environment.etc."nextcloud-admin-pass".text = "changeme";

  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "${myDomain},${myIp},x220,x220.fable-ph.ts.net";

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
              href = "http://${myDomain}/grafana";
              icon = "grafana";
            };
          }

          {
            Blocky = {
              href = "http://${myDomain}/blocky"; # Blocky WebUI or metrics
            icon = "blocky";

            };

          }

          {

            Nextcloud = {

              href = "http://${myDomain}/nextcloud";

              icon = "nextcloud";

            };

          }

        ];
      }
    ];
  };

  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };


}
