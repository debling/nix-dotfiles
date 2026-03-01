{
  # Locale and timezone
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
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
    layout = "br";
    options = "caps:escape";
  };
  services.xserver.wacom.enable = true;
  services.libinput.enable = true;
}
