# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, mainUser, ... }:

{
  imports =
    [
      ../../modules/common/containers.nix
      ../../modules/common/fonts.nix
      ../../modules/common/networking.nix
      ../../modules/common/nix.nix
      ../../modules/common/pipewire.nix
      ../../modules/desktop/dwl
      ../../modules/hardware/bluetooth.nix
      ../../modules/home-assistant.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernel.sysctl."vm.swappiness" = 200;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  zramSwap = {
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${mainUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "docker"
      "podman" # docker and podman without sudo
    ];
    hashedPassword = "$y$j9T$O4qn0aOF8U9FQPiMXsv41/$CkOtnJbkV4lcZcCwQnUL0u4xlfoYhvN.9pCUzT2uFI5";
    shell = pkgs.fish;
  };
  security.sudo.wheelNeedsPassword = false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
  ];

  home-manager.users.${mainUser} = import ./home.nix;

  networking.hostName = "x220"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services = {
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    displayManager.autoLogin.user = mainUser;

    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      xkb = {
        layout = "br";
        variant = "thinkpad";
        options = "caps:escape"; # map caps to escape.
      };
    };

    tlp.enable = true;
    power-profiles-daemon.enable = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      bluez
      # uxplay
      # neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      tmux
      wget
      # alacritty
      git

      # bitwarden
      # bitwarden-cli
      # spotify
    ];


    sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs = {
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    zsh.enable = true;
    neovim.enable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
