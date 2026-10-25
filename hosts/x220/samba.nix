{ config, pkgs, ... }:

{
  # 1. Create the dedicated netshare user
  #
  # netshare is the machine account for local-network service mounts — the
  # ryzen CIFS mount of the media library (hosts/ryzen/media-share.nix)
  # connects with its agenix-protected credential. It gets read access to
  # /srv/media via the media group.
  users.users.netshare = {
    isSystemUser = true;
    group = "netshare";
    description = "Dedicated network share user";
    extraGroups = [ "media" ];
  };
  users.groups.netshare = { };

  # Create users for private shares
  users.users.vivianedn = {
    isNormalUser = true;
    description = "Viviane's user for Samba";
  };

  # 2. Create the storage directories
  systemd.tmpfiles.rules = [
    "d /srv/samba/public 0777 netshare netshare -"
    "d /srv/samba/debling 0770 debling debling -"
    "d /srv/samba/vivianedn 0770 vivianedn vivianedn -"
  ];

  # 3. Configure Samba
  services.samba = {
    enable = true;
    openFirewall = true;
    package = pkgs.samba4Full;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS-HomeServer";
        "security" = "user";
        "min protocol" = "SMB2";
        "server signing" = "mandatory";
        "smb encrypt" = "desired";
        # macOS Optimization
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "RackMac";
      };

      "public" = {
        "path" = "/srv/samba/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "netshare";
        "force group" = "netshare";
        "create mask" = "0666";
        "directory mask" = "0777";
      };

      # Whole media library, read-only: consumption for mac/win/linux
      # machines and the ryzen jellyfin mount. Writing happens on x220
      # itself (transmission/arrs/tdarr); re-enable a separate rw share
      # if manual additions from the LAN are wanted.
      "media" = {
        "path" = "/srv/media";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "debling vivianedn netshare";
        "force group" = "media";
        "hide files" = "/.*/";
      };

      "debling" = {
        "path" = "/srv/samba/debling";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "debling";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      "viviane" = {
        "path" = "/srv/samba/vivianedn";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "vivianedn";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # 3. Enable Avahi (mDNS) so Mac/Linux can see the server as "nixserver.local"
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };

  # 4. Windows discovery support (optional, useful for Android discovery too)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
