{ pkgs, colorscheme, ... }:

{
  services.mako = with colorscheme.palette; {
    enable = true;
    settings = {
      default-timeout = 10 * 1000;
      layer = "overlay";
      icon-path = "${pkgs.rose-pine-icon-theme}/share/icons/rose-prine-dawn";
      background-color = "#${base00}";
      text-color = "#${base05}";
      border-color = "#${base0D}";
      progress-color = "#${base02}";
    };
    criteria = {
      "urgency=low" = {
        background-color = "#${base00}";
        text-color = "#${base0A}";
        border-color = "#${base0D}";
      };

      "urgency=high" = {
        background-color = "#${base00}";
        text-color = "#${base08}";
        border-color = "#${base0D}";
      };
    };
  };
}
