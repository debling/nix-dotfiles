{ config, lib, pkgs, nix-index-database, android-nixpkgs, mainUser, ... }:

{
  imports = [
    nix-index-database.hmModules.nix-index
    android-nixpkgs.hmModule

    ../../modules/editors/neovim.nix
    ../../modules/home/common-packages.nix
    ../../modules/home/gtk-qt.nix
    ../../modules/home/version-control.nix
    ../../modules/terminals/alacritty.nix
  ];

  debling.editors.neovim.enable = true;

  debling.alacritty.enable = true;

  news.display = "show";

  nix = {
    checkConfig = true;
    settings = {
      experimental-features = "nix-command flakes";
      extra-platforms = "x86_64-darwin aarch64-darwin";
      substituters = "https://cache.nixos.org https://debling.cachix.org";
      trusted-public-keys =
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= debling.cachix.org-1:S2Zx2LNGAF1DIYoxKyVcqk7h/XMLLjxHLjfeHsOkgWo=";
    };
  };

  android-sdk = {
    enable = true;

    path = "${config.home.homeDirectory}/SDKs/android";

    packages = sdk: with sdk; [
      build-tools-30-0-0
      build-tools-30-0-3
      cmdline-tools-latest
      emulator
      platforms-android-33
      platform-tools
      sources-android-33
      ndk-23-1-7779620
      cmake-3-22-1
    ];
  };

  home = {
    sessionVariables = {
      TERMINAL = lib.getExe pkgs.alacritty;
    };

    enableNixpkgsReleaseCheck = true;

    packages = with pkgs; [
      babashka
      gh

      gnumake
      snitch
      maven

      ### Editors/IDEs
      # jetbrains.datagrip
      # jetbrains.idea-ultimate
      visualvm

      ### Langs related
      # idris2 # A language with dependent types, XXX: compilation is broken on m1 for now https://github.com/NixOS/nixpkgs/issues/151223
      # ansible
      clojure # Lisp language with sane concurrency
      nodejs
      nodePackages.pnpm
      pipenv

      (python312.withPackages (ps: with ps; [
        pandas
        numpy
        ipython
        matplotlib
        seaborn
        # jupyterlab
        pudb
        # torch
        boto3
        scikit-learn
      ]))
      poetry


      # unrar
      postgresql_15

      # vagrant
      # https://github.com/mic92/nix-update
      # nix-init # https://github.com/nix-community/nix-init
      oha # HTTP load generator https://github.com/hatoo/oha

      cht-sh # https://github.com/chubin/cheat.sh
      # nix-du

      # https://magic-wormhole.readthedocs.io/en/latest/welcome.html#example
      # magic-wormhole # Send files over the network

      glow
    ];

  };

  xdg.configFile = {
    snitch = {
      source = ./../../config/snitch;
      recursive = true;
    };
  };

  programs = {
    nushell.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        { name = "done"; src = pkgs.fishPlugins.done.src; }
      ];

      # FIXME: This is needed to address bug where the $PATH is re-ordered by
      # the `path_helper` tool, prioritising Apple’s tools over the ones we’ve
      # installed with nix.
      #
      # This gist explains the issue in more detail: https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
      # There is also an issue open for nix-darwin: https://github.com/LnL7/nix-darwin/issues/122
      loginShellInit =
        let
          # We should probably use `config.environment.profiles`, as described in
          # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
          # but this takes into account the new XDG paths used when the nix
          # configuration has `use-xdg-base-directories` enabled. See:
          # https://github.com/LnL7/nix-darwin/issues/947 for more information.
          profiles = [
            "/etc/profiles/per-user/$USER" # Home manager packages
            "$HOME/.nix-profile"
            "(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nix/profile"
            "/run/current-system/sw"
            "/nix/var/nix/profiles/default"
          ];

          makeBinSearchPath =
            lib.concatMapStringsSep " " (path: "${path}/bin");
        in
        lib.mkIf pkgs.stdenv.isDarwin
          ''
            # Fix path that was re-ordered by Apple's path_helper
            fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
            set fish_user_paths $fish_user_paths
          '';
    };

    tmux = {
      enable = true;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "alacritty";
      sensibleOnTop = false;
      tmuxp.enable = true;
      extraConfig = ''
        # Terminal config for TrueColor support
        # set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # colored underscores
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0
        set -as terminal-overrides ",*:RGB"  # true-color support


        set -g focus-events on

        set -g mouse on

        set -g set-titles on
        set -g set-titles-string "#S / #W"

        set -g status-style "none,bg=default"
        set -g status-justify centre
        set -g status-bg colour8
        set -g status-fg colour15
        set -g status-left-length 25
        set -g status-right '%d/%m %H:%M'

        setw -g window-status-current-format '#[bold]#I:#W#[fg=colour5]#F'
        setw -g window-status-format '#[fg=colour7]#I:#W#F'

        # Open new splits in the same directory as the current pane
        bind  %  split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    };
  };


  systemd.user.startServices = "sd-switch";


  ####
  #### The section bellow is auto-generated by home-manager
  ####

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = mainUser;
  home.homeDirectory = "/Users/${mainUser}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
