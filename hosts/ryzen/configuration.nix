# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
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
    ../../modules/common/steam.nix
    # ../../modules/nixos/desktop/river.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/bluetooth.nix
    ./alloy.nix
  ];
  programs.mosh.enable = true;
  programs.mosh.openFirewall = true;

  home-manager.users.${mainUser} = import ./home.nix;

  hardware.facter.reportPath = ./facter.json;

  zramSwap = {
    enable = true;
    memoryPercent = 35;
  };

  documentation.dev.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # hardware.opentabletdriver.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  boot = {
    kernel.sysctl."vm.swappiness" = 200;

    loader.timeout = 0;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "ryzen"; # Define your hostname.
    interfaces.enp37s0 = {
      wakeOnLan.enable = true;
    };
  };

  # Configure keymap in X11
  services = {
    kmonad = {
      enable = false;
      keyboards = {
        k6Out = {
          defcfg.enable = false;
          device = "/dev/input/by-id/usb-Keychron_Keychron_K6-event-kbd";
          config = builtins.readFile ../../modules/keyboard/keyboard.kbd;
        };
      };
    };
    # Enable CUPS to print documents.
    printing.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rose-pine-icon-theme
    zen-browser
    man-pages
    man-pages-posix
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

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
