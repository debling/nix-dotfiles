{ pkgs, ... }:
{
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
  };

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix = {
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
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  environment.systemPackages = with pkgs; [
    pinentry_mac 
  ];

  security.pam.enableSudoTouchIdAuth = true;

  services = {
    yabai = {
      enable = true;
      config = {
        # default layout (can be bsp, stack or float)
        layout = "bsp";
        window_border = "off";
        window_shadow = "float";
        # New window spawns to the right if vertical split, or bottom if horizontal split
        window_placement = "second_child";

        # modifier for clicking and dragging with mouse
        mouse_modifier = "alt";
        mouse_drop_action = "swap";

        # padding set to 8px
        top_padding = 8;
        bottom_padding = 8;
        left_padding = 8;
        right_padding = 8;
        window_gap = 8;

        window_opacity = "on";
        active_window_opacity = "1.0";
        normal_window_opacity = "0.9";
      };
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
      "maccy"
      "miniconda"
      "obsidian"
      "slack"
      "spotify"
    ];
  };
}
