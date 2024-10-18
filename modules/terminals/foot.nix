{
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "monospace:size=12";
      };
      scrollback = {
        lines = 0; # disable scrollbacl, tmux does it better
      };
    };
  };
}
