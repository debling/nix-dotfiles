{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        include = "${pkgs.foot.themes}/share/foot/themes/modus-vivendi";
        font = "monospace:size=14";
      };
      scrollback = {
        lines = 0; # disable scrollbacl, tmux does it better
      };
    };
  };
}
