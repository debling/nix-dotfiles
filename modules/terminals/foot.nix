{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      include = "${pkgs.foot.themes}/share/foot/themes/modus-operandi";
      main = {
        font = "monospace:size=12";
      };
      scrollback = {
        lines = 0; # disable scrollbacl, tmux does it better
      };
    };
  };
}
