{ pkgs, colorscheme, ... }:

{
  services.mako = with colorscheme.palette; {
    enable = true;
    defaultTimeout = 10 * 1000;
    layer = "overlay";
    iconPath = "${pkgs.rose-pine-icon-theme}/share/icons/rose-prine-dawn";
    backgroundColor = "#${base00}";
    textColor = "#${base05}";
    borderColor = "#${base0D}";
    progressColor = "#${base02}";
    extraConfig = ''
      [urgency=low]
      background-color=#${base00}
      text-color=#${base0A}
      border-color=#${base0D}

      [urgency=high]
      background-color=#${base00}
      text-color=#${base08}
      border-color=#${base0D}
    '';
  };
}

