{ lib, ... }:

{
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.wifi.backend = "iwd";

  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;

  networking.firewall.enable = lib.mkDefault true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = lib.mkDefault true;

  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;

  # Keep dmesg/journalctl -k output readable by NOT logging
  # each refused connection on the open internet.
  networking.firewall.logRefusedConnections = lib.mkDefault false;

  # Allows to find machines on the local network by name, i.e. useful for printer discovery
  systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
  systemd.network.networks."99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
  networking.firewall.allowedUDPPorts = [ 5353 ]; # Multicast DNS

  # Improve boot time by not waiting for network
  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
