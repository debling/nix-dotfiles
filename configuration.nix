{ pkgs, ... }:
{
  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix = {
    package = pkgs.nixUnstable;
    configureBuildUsers = true;
    settings = {
      trusted-users = [ "debling" "@admin" ];
      auto-optimise-store = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    useDaemon = true;
  };

  programs = {
    # Create /etc/bashrc that loads the nix-darwin environment.
    zsh.enable = true;
  };

  # Fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      jetbrains-mono
      nerdfonts
    ];
  };

  environment.systemPackages = with pkgs; [ ncurses ];

  security.pam.enableSudoTouchIdAuth = true;

  services = {
    yabai = {
      enable = true;
      extraConfig = builtins.readFile ./config/yabai/yabairc;
    };

    skhd = {
      enable = true;
      skhdConfig = builtins.readFile ./config/skhd/skhdrc;
    };
  };

  # TODO: Move this config to home-manager
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      NSGlobalDomain = {
        # start key repeat after holdinng a key for 40ms
        InitialKeyRepeat = 40;
        # Rate of keyrepeat in hz
        KeyRepeat = 60;
        # com.apple.sound.beep.volume = 0;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      dock = {
        autohide = true;
        tilesize = 32;
      };
      finder.AppleShowAllFiles = true; # Show hidden files
      screencapture.type = "png";
    };
  };

  homebrew = {
    enable = true;
    casks = [
      "android-studio"
      "anydesk"
      "bitwarden"
      "docker"
      "iterm2"
      "miniconda"
      "obsidian"
      "slack"
      "spotify"
    ];
  };
}
