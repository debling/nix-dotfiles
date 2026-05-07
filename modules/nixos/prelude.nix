{ pkgs, ... }:
{
  # Locale and timezone
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v14n"; # Change 'v32n' to your preferred size/style
    earlySetup = true; # Applies font as early as possible during boot
    useXkbConfig = true;
  };

  # Base programs
  programs = {
    mtr.enable = true;
    fish.enable = true;
    neovim.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Avahi (mDNS)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # X11 keyboard configuration (applies only if X server is enabled)
  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };
  services.xserver.wacom.enable = true;
  services.libinput.enable = true;
}
