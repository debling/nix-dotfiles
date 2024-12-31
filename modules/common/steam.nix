{ pkgs, mainUser, ... }:

{
  users.users.${mainUser}.extraGroups = [ "gamemode" ];

  programs = {
    gamescope.enable = true;

    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

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
