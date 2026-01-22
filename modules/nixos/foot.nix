{
  lib,
  pkgs,
  colorscheme,
  ...
}:

{
  programs.foot = {
    enable = pkgs.stdenv.isLinux;
    server.enable = true;
    settings = {
      main = {
        shell = lib.getExe pkgs.fish;
        font = "monospace:size=12";
        pad = "14x14";
      };
      colors-dark = with colorscheme.palette; {
        alpha = 0.92;
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
