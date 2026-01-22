{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.glauth;
  settingsFormat = pkgs.formats.toml { };

in
{
  options.services.glauth = {
    enable = lib.mkEnableOption "Glauth LDAP server";

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = { };
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "glauth";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "glauth";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/glauth";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      extraGroups = [ "nginx" ];
    };
    users.groups.${cfg.group} = { };

    environment.etc."glauth.cfg".source = settingsFormat.generate "glauth-config" cfg.settings;

    systemd.services.glauth = {
      description = "Glauth LDAP server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        ExecStart = "${pkgs.glauth}/bin/glauth -c /etc/glauth.cfg";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        StateDirectory = "glauth";
        StateDirectoryMode = "0750";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [ 636 ];
  };
}
