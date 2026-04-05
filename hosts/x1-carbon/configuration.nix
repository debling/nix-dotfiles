# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  lib,
  pkgs,
  mainUser,
  ...
}:

{
  imports = [
    ../../modules/nixos/prelude.nix
    ../../modules/nixos/users.nix
    ../../modules/common/containers.nix
    ../../modules/common/fonts.nix
    ../../modules/common/networking.nix
    ../../modules/common/nix.nix
    ../../modules/common/pipewire.nix
    # ../../modules/nixos/desktop/river.nix
    ../../modules/nixos/keyboard.nix
    ../../modules/nixos/bluetooth.nix
  ];
  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = mainUser;
  };

  services.system76-scheduler.enable = true;
  programs.firefox.preferences = {
    # disable libadwaita theming for Firefox
    "widget.gtk.libadwaita-colors.enabled" = false;
  };
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

  hardware.facter.reportPath = ./facter.json;

  networking.firewall.allowedTCPPorts = [
    5555 # Common port for ADB over Wi-Fi
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    }
  ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = 49152;
      to = 65535;
    }
    {
      from = 1714;
      to = 1764;
    }
  ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  zramSwap = {
    enable = true;
    memoryPercent = 35;
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # swapDevices = [
  #   {
  #     device = "/var/swapfile";
  #     size = 2 * 1024; # 4GB
  #   }
  # ];

  documentation.dev.enable = true;

  hardware.opentabletdriver.enable = true;

  home-manager.users.${mainUser} = import ./home.nix;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [ "quiet" ];
    kernel.sysctl."vm.swappiness" = 200;

    loader.timeout = 0;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking.hostName = "x1-carbon"; # Define your hostname.

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  # Configure keymap in X11
  services = {
    udev = {
      extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="4200", MODE="0666", SYMLINK+="nirscan_hidraw%n"
      '';

      packages = [
        pkgs.platformio-core
        pkgs.openocd
        pkgs.flashrom
      ];
    };

    xserver = {
      # Enable the GNOME Desktop Environment.
      # displayManager.gdm.enable = true;
      # desktopManager.gnome.enable = true;
    };

  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  cosmic-clipboard-manager
    zen-browser
    man-pages
    man-pages-posix

    platformio-core
    openocd
    flashrom

    uv

    android-tools
  ];
  environment.localBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
  services.fprintd.enable = true;

  programs.kdeconnect.enable = true;
}
