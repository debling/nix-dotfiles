# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, mainUser, ... }:

{
  imports =
    [
      ../../modules/common/containers.nix
      ../../modules/common/fonts.nix
      ../../modules/common/networking.nix
      ../../modules/common/nix.nix
      ../../modules/common/pipewire.nix
      ../../modules/nixos/desktop/river.nix
      ../../modules/nixos/keyboard.nix
      ../../modules/nixos/bluetooth.nix
    ];

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.debling = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo commands without password
      "docker" # docker commands without root
      "podman" # podman commands without root
      "adbusers" # android `adb` command
      "input"
      "uinput" # access to udev access (in use by kmonad)
      "dialout" # access to wserial ports
      "kvm" # access to wserial ports
    ];
    hashedPassword = "$y$j9T$O4qn0aOF8U9FQPiMXsv41/$CkOtnJbkV4lcZcCwQnUL0u4xlfoYhvN.9pCUzT2uFI5";
  };


  security.sudo.wheelNeedsPassword = false;

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

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
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


    greetd = {
      enable = true;
      settings =
        {
          initial_session = {
            user = "debling";
            command = "river";
          };
          default_session = {
            command =
              ''
                ${lib.getExe pkgs.tuigreet} \
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
      # Enable the GNOME Desktop Environment.
      # displayManager.gdm.enable = true;
      # desktopManager.gnome.enable = true;
      xkb = {
        layout = "br";
        options = "caps:escape"; # map caps to escape.
      };
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    zen-browser
    man-pages
    man-pages-posix

    platformio-core
    openocd
    flashrom

    uv
  ];
  environment.localBinInPath = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    fish.enable = true;
    neovim.enable = true;
    adb.enable = true;
  };

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

  services.tlp.enable = true;
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";
}
