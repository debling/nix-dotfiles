{ pkgs, mainUser, ... }:

{
  users.users.${mainUser}.extraGroups = [ "gamemode" ];

  programs = {
    steam.enable = true;

    gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 19;
        };

        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };
}
