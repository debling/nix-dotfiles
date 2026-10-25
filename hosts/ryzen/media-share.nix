# Network share of the media library on x220.
#
# Jellyfin (and only Jellyfin) reads /srv/media from x220 over SMB instead
# of NFS: the same samba share that macOS/Windows/Linux machines use for
# normal file access. The mount is read-only because the *arr stack,
# transmission and tdarr keep writing on x220 itself; jellyfin only reads.
#
# Note: the mount path must stay /srv/media so the migrated library DB's
# item paths keep matching (no rescan after cutover).
#
# Secret identity: age refuses this host's OpenSSH ED25519 private key as
# an identity directly ("no identity matched any of the recipients"), so
# the key is converted with `ssh-to-age -i /etc/ssh/ssh_host_ed25519_key
# -private-key` and provisioned by hand at /etc/agenix/age-identity
# (root:600) on the host; agenix is pointed there. To regenerate after a
# reinstall:
#   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key -private-key \
#     > /etc/agenix/age-identity && chmod 600 /etc/agenix/age-identity
{
  config,
  pkgs,
  ...
}:

{
  age.identityPaths = [ "/etc/agenix/age-identity" ];

  # Matches the gid pinned in hosts/x220/arr.nix, so a CIFS mount using
  # gid=1200 maps onto the same group identity for whatever needs it.
  users.groups.media.gid = 1200;

  age.secrets.media-share-cred.file = ../../secrets/media-share-cred.age;

  boot.supportedFilesystems = [ "cifs" ];
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/srv/media" = {
    # x220 resolves via the LAN dns (dnsmasq host-record in
    # hosts/x220/networking.nix — "x220" was added to lanServices for this).
    # Fallback if that resolution misbehaves: //10.0.10.1/media
    device = "//x220.home.debling.com.br/media";
    fsType = "cifs";
    options = [
      "credentials=${config.age.secrets.media-share-cred.path}"
      "ro"
      "vers=3.1.1"
      "noserverino"
      "actimeo=600"
      # automount on access with fail-soft boot: x220 rebooting shouldn't
      # hang ryzen's boot; jellyfin's RequiresMountsFor handles ordering
      "x-systemd.automount"
      "nofail"
      "x-systemd.mount-timeout=30"
    ];
  };
}
