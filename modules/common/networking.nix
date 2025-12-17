{ lib, ... }:

{
  # Use networkd instead of the pile of shell scripts
  networking.useNetworkd = lib.mkDefault true;

  networking.firewall.enable = lib.mkDefault true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = lib.mkDefault true;

  # Allow PMTU / DHCP
  networking.firewall.allowPing = true;
}
