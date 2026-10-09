{
  config,
  lib,
  pkgs,
  ...
}:

let
  myIp = "10.0.10.1";
  routerIp = "10.0.0.1";
  domain = "home.debling.com.br";

  # Service names in this LAN domain. DNS records are generated explicitly
  # from this list — there is no wildcard fallback, so unknown names
  # (foo.home.debling.com.br) return NXDOMAIN. Adding a service here is
  # required for it to resolve.
  lanServices = [
    "grafana"
    "authelia"
    "penpot"
    "nextcloud"
    "forgejo"
    "paperless"
    "office"
    "jellyfin"
    "seerr"
    "transmission"
    "tdarr"
    "sonarr"
    "prowlarr"
    "radarr"
    "lidarr"
    "bazarr"
    "otlp"
    "assistant"
  ];

  dhcp-event-hook = pkgs.buildGoModule {
    pname = "dhcp-event-hook";
    version = "0.1.0";
    src = ./dhcp-event-hook;
    vendorHash = "sha256-0UkzlWkeDopzFruNEBY0COoK8nRvwHGyefBAVOVsDfo=";
  };
in
{
  networking = {
    domain = domain;
    search = [ domain ];
    hosts = {
      "127.0.0.2" = lib.mkForce [ ];
    };
    useNetworkd = true;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [
        80
        443
        53
        22
        9090
      ];
      allowedUDPPorts = [
        53
        67
      ];
    };
    hostName = "x220";
    hosts = {
      "127.0.0.1" = [ "x220" ];
    };
    useDHCP = false;
    enableIPv6 = false;
    interfaces.enp0s25 = {
      ipv4.addresses = [
        {
          address = myIp;
          prefixLength = 16;
        }
      ];
      useDHCP = false;
      wakeOnLan.enable = true;
    };
    defaultGateway = {
      address = routerIp;
      interface = "enp0s25";
    };
    nameservers = [ "127.0.0.1" ];
  };

  services.resolved.settings.Resolve.DNSStubListener = "no";

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      dns-forward-max = 1000;
      port = 5453;
      listen-address = [
        "127.0.0.1"
        myIp
      ];
      domain = domain;
      local = "/${domain}/";
      # Stop dnsmasq from serving x220's own /etc/hosts (which maps
      # 127.0.0.1 to "x220") to the whole LAN, poisoning
      # x220.home.debling.com.br for remote clients (e.g. ryzen's alloy
      # remote_write). x220 itself still resolves it locally via NSS.
      no-hosts = true;
      expand-hosts = true;
      dhcp-authoritative = true;
      log-dhcp = true;

      dhcp-range = [ "10.0.0.100,10.0.0.200,255.255.0.0,12h" ];
      dhcp-option = [
        "3,${routerIp}"
        "6,${myIp}"
        "15,${domain}"
        "option:domain-search,${domain}"

      ];
      dhcp-host = [
        "30:9c:23:02:e9:b6,10.0.10.2,ryzen"
      ];

      host-record = [
        "router.${domain},${routerIp}"
        "${domain},${myIp}" # apex (homepage)
      ]
      ++ map (s: "${s}.${domain},${myIp}") lanServices;

      #dhcp-script = "${dhcp-event-hook}/bin/dhcp-event-hook";
      #script-arp = true;
    };
  };

  services.blocky = {
    enable = true;
    settings = {
      ports.http = 4000;      upstreams.groups.default = [
        "https://dns.quad9.net/dns-query"
        "https://1.1.1.1/dns-query"
        "tcp-tls:1.1.1.1:853"
      ];
      bootstrapDns = "9.9.9.9";

      conditional.mapping = {
        "${domain}" = "127.0.0.1:5453";
        "." = "127.0.0.1:5453";
      };

      customDNS = {
        customTTL = "1h";
      };
      prometheus.enable = true;
      caching.prefetching = true;
      blocking = {
        denylists = {
          ads = [ "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/ultimate.txt" ];
          fake = [ "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/fake.txt" ];
          threats = [ "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.txt" ];
        };
        allowlists.ads = [ ''
            *.graph.whatsapp.com
        ''];
        clientGroupsBlock.default = [
          "ads"
          "fake"
          "threats"
        ];
        blockType = "zeroIp";
      };
      queryLog = {
        type = "timescale";
        target = "postgres://blocky@127.0.0.1:5432/blocky";
        logRetentionDays = 30;
      };
      clientLookup = {
        upstream = "127.0.0.1:5453";
        singleNameOrder = [ 1 ];
      };
    };
  };
}
