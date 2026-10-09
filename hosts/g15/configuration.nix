# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
#
# Dell G15 5530: cloned from hosts/x1-carbon.
# Hardware specifics filled in from the machine itself (i5-13450HX, Intel UHD +
# RTX 3050 hybrid, ADATA NVMe, BOE 1920x1080 panel); see ./displays.nix and
# ./disko.nix. Still open:
#   * ./facter.json is the x1-carbon report as a placeholder; nixos-anywhere
#     regenerates it (`--generate-hardware-config nixos-facter
#     ./hosts/g15/facter.json`) — commit the regenerated file post-install.
#   * HDMI output name under the nvidia driver (maybe `HDMI-1-0`) — confirm
#     with `xrandr` post-install and update ./displays.nix if needed.

{
  lib,
  pkgs,
  mainUser,
  ...
}:

{
  imports = [
    ./displays.nix
    ../../modules/nixos/prelude.nix
    ../../modules/nixos/users.nix
    ../../modules/common/containers.nix
    ../../modules/common/fonts.nix
    ../../modules/common/networking.nix
    ../../modules/common/nix.nix
    ../../modules/common/pipewire.nix
    ../../modules/common/steam.nix
    ../../modules/nixos/desktop/dwm
    ../../modules/nixos/keyboard.nix
    ../../modules/nixos/bluetooth.nix
  ];

  hardware.facter.reportPath = ./facter.json;

  # Hybrid graphics (Dell G15 5530): Intel UHD (Raptor Lake) drives the
  # internal panel; the RTX 3050 6GB Laptop GPU is used on demand. The HDMI
  # port is wired to the NVIDIA card, so the nvidia driver is required for
  # external displays.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # from `cat /sys/bus/pci/devices/*/device | head` (iGPU 00:02.0, dGPU 01:00.0)
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

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
    extraUpFlags = [ "--accept-routes" ];
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

  networking.hostName = "g15"; # Define your hostname.

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
    #cosmic-clipboard-manager
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

  programs.kdeconnect.enable = true;
}
