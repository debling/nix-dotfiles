{ config, pkgs, ... }:

{
  # 1. Create the dedicated netshare user
  users.users.netshare = {
    isSystemUser = true;
    group = "netshare";
    description = "Dedicated network share user";
  };
  users.groups.netshare = {};

  # 2. Create the storage directory owned by netshare
  systemd.tmpfiles.rules = [
    "d /srv/samba/shared 0770 netshare netshare -"
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
        # macOS Optimization
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
      };

      "SharedFiles" = {
        "path" = "/srv/samba/shared";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        # Force all files created via network to be owned by netshare
        "force user" = "netshare";
        "force group" = "netshare";
        "create mask" = "0660";
        "directory mask" = "0770";
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
