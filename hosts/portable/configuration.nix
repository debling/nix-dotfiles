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
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/nixos/prelude.nix
    ../../modules/nixos/users.nix
    ../../modules/common/containers.nix
    ../../modules/common/fonts.nix
    ../../modules/common/networking.nix
    ../../modules/common/nix.nix
    ../../modules/common/pipewire.nix
    ../../modules/common/steam.nix
    # ../../modules/desktop/dwl
    ../../modules/nixos/desktop/river.nix
    ../../modules/nixos/nvidia.nix
    #../../modules/hardware/nouveau.nix
    ../../modules/nixos/bluetooth.nix
  ];

  documentation.dev.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.opentabletdriver.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxKernel.kernels.linux_zen;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    memtest86.enable = true;
    extraEntries = ''
      menuentry "Reboot" --class restart {
        reboot
      }

      menuentry "Shutdown" --class shutdown {
        halt
      }
    '';
  };

  networking.hostName = "nixos-portable"; # Define your hostname.

  # Configure keymap in X11
  services = {
    kmonad = {
      enable = true;
      keyboards = {
        k6Out = {
          defcfg.enable = false;
          device = "/dev/input/by-id/usb-Keychron_Keychron_K6-event-kbd";
          config = builtins.readFile ../../modules/keyboard/keyboard.kbd;
        };
      };
    };

    udev.extraRules = ''
      KERNEL=="hidraw*", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="4200", MODE="0666", SYMLINK+="nirscan_hidraw%n"
    '';

    greetd = {
      enable = true;
      settings = {
        initial_session = {
          user = "debling";
          command = "river";
        };
        default_session = {
          command = ''
            ${lib.getExe pkgs.greetd.tuigreet} \
              --cmd river \
              --asterisks --remember --remember-user-session --time
          '';
          user = "debling";
        };
      };
    };

    displayManager = {
      autoLogin.user = mainUser;
    };

    xserver = {

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rose-pine-icon-theme
    zen-browser
    man-pages
    man-pages-posix
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

  services.fstrim.enable = true;
  services.tlp.enable = true;
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
