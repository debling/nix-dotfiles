# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, mainUser, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ../../modules/common/containers.nix
      ../../modules/common/fonts.nix
      ../../modules/common/networking.nix
      ../../modules/common/nix.nix
      ../../modules/common/pipewire.nix
      ../../modules/common/steam.nix
      ../../modules/desktop/dwl
      ../../modules/hardware/nvidia.nix
      ../../modules/hardware/bluetooth.nix
    ];

  documentation.dev.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.debling = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "$y$j9T$O4qn0aOF8U9FQPiMXsv41/$CkOtnJbkV4lcZcCwQnUL0u4xlfoYhvN.9pCUzT2uFI5";
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager.users.${mainUser} = import ./home.nix;

  boot.kernel.sysctl."vm.swappiness" = 200;

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
    greetd = {
      enable = true;
      settings =
        {
          initial_session = {
            user = "debling";
            command = "dwl-run";
          };
          default_session = {
            command =
              ''
                ${lib.getExe pkgs.greetd.tuigreet} \
                  --cmd dwl-run \
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
    rose-pine-icon-theme
    firefox
    zen-browser
  ];

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

  services.fstrim.enable = true;
  services.tlp.enable = true;
}
