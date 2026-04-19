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

  dhcp-event-hook = pkgs.buildGoModule {
    pname = "dhcp-event-hook";
    version = "0.1.0";
    src = ./dhcp-event-hook;
    vendorHash = "sha256-0UkzlWkeDopzFruNEBY0COoK8nRvwHGyefBAVOVsDfo=";
  };
in
{
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
      allowedUDPPorts = [
        53
        67
      ];
    };
    hostName = "x220";
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
      port = 5453;
      listen-address = [
        "127.0.0.1"
        myIp
      ];
      domain = domain;
      local = "/${domain}/";
      expand-hosts = true;
      authoritative = true;
      log-dhcp = true;

      dhcp-range = [ "10.0.0.100,10.0.0.200,255.255.0.0,12h" ];
      dhcp-option = [
        "3,${routerIp}"
        "6,${myIp}"
        "15,${domain}"
      ];
      dhcp-host = [
        "30:9c:23:02:e9:b6,10.0.10.2,ryzen"
      ];

      host-record = [
        "x220,${myIp}"
      ];

      dhcp-script = "${dhcp-event-hook}/bin/dhcp-event-hook";
      script-arp = true;
    };
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
      ];
      bootstrapDns = "9.9.9.9";

      conditional.mapping = {
        "${domain}" = "127.0.0.1:5453";
      };

      customDNS = {
        customTTL = "1h";
        mapping = {
          "router.arpa" = routerIp;
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
        upstream = routerIp;
        singleNameOrder = [ 1 ];
      };
    };
  };
}
