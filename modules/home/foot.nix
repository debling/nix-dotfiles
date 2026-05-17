{
  lib,
  pkgs,
  colorscheme,
  ...
}:

{
  systemd.user.services.foot.Service.Environment =
    let
      paths = lib.makeBinPath [
        # necessary for ctrl+shit+n to work (spawn a new instance on the current dir)
        pkgs.foot
        #  for desktop notification via OSC 777 and OSC 99 to work
        pkgs.libnotify
        # for openning links using xdg-open
        pkgs.xdg-utils
      ];
    in
    [
      "PATH=${paths}"
    ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        shell = lib.getExe pkgs.fish;
        font = "monospace:size=12";
        pad = "14x14";
      };
      desktop-notifications.inhibit-when-focused = false;
      colors-dark = with colorscheme.palette; {
        foreground = base05;
        background = base00;
        regular0 = base00; # black
        regular1 = base08; # red
        regular2 = base0B; # green
        regular3 = base0A; # yellow
        regular4 = base0D; # blue
        regular5 = base0E; # magenta
        regular6 = base0C; # cyan
        regular7 = base05; # white
        bright0 = base02; # bright black
        bright1 = base08; # bright red
        bright2 = base0B; # bright green
        bright3 = base0A; # bright yellow
        bright4 = base0D; # bright blue
        bright5 = base0E; # bright magenta
        bright6 = base0C; # bright cyan
        bright7 = base07; # bright white
        "16" = base09;
        "17" = base0F;
        "18" = base01;
        "19" = base02;
        "20" = base04;
        "21" = base06;
      };
    };
  };
}
