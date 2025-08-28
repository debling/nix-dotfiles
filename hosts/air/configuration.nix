{ pkgs, mainUser, ... }:
{
  home-manager.users.${mainUser} = import ./home.nix;

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      trusted-users = [ "debling" "@admin" ];
      # auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      extra-platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    };

    # Enable the linux builder, which allows to build packages, and most important
    # use the build-vm feature
    linux-builder.enable = false;
  };

  programs = {
    # Create /etc/bashrc that loads the nix-darwin environment.
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
      enableFzfGit = true;
    };

    fish = {
      enable = true;
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  environment.systemPackages = with pkgs; [
    pinentry_mac

    # Linux programing api pages
    man-pages-posix
  ];

  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
  };

  services = {
    # karabiner-elements.enable = true;

    yabai = {
      enable = false;
      enableScriptingAddition = true;
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
        top_padding = 0;
        bottom_padding = 0;
        left_padding = 0;
        right_padding = 0;
        window_gap = 8;

        window_opacity = "on";
        active_window_opacity = "1.0";
        normal_window_opacity = "0.8";

        window_animation_duration = 0.0;
      };
      extraConfig = builtins.readFile ../../config/yabai/yabairc;
    };

    skhd = {
      enable = true;
      skhdConfig = builtins.readFile ../../config/skhd/skhdrc;
    };
  };

  system = {
    primaryUser = mainUser;
    stateVersion = 5;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        NSAutomaticWindowAnimationsEnabled = true;

        _HIHideMenuBar = true;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      dock = {
        autohide = true;
        autohide-delay = 0.1;
        autohide-time-modifier = 0.1;
        expose-animation-duration = 0.1;

        tilesize = 32;
      };
      finder.AppleShowAllFiles = true; # Show hidden files
      screencapture.type = "png";
    };
  };

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      cleanup = "zap";
    };
    casks = [
      "android-studio"
      "anydesk"
      "bitwarden"
      "keycastr"
      "maccy"
      "obsidian"
      "slack"
      "spotify"
      "stremio"
      "orbstack"
      "ghostty"
      "karabiner-elements"
      "libreoffice"
    ];
  };
}
