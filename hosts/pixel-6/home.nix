{ config, lib, pkgs, nix-index-database, mainUser, ... }:

{
  imports = [
    ./modules/editors/neovim.nix
    ./modules/home/version-control.nix
    nix-index-database.hmModules.nix-index
  ];

  debling.editors.neovim.enable = true;

  nix = {
    checkConfig = true;
    settings = {
      experimental-features = "nix-command flakes";
      # extra-platforms = "x86_64-darwin aarch64-darwin";
      substituters = "https://cache.nixos.org https://debling.cachix.org";
      trusted-public-keys =
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= debling.cachix.org-1:S2Zx2LNGAF1DIYoxKyVcqk7h/XMLLjxHLjfeHsOkgWo=";
    };
  };


  home = {
    enableNixpkgsReleaseCheck = true;

    packages = with pkgs;
      [
        babashka
        gh

        gnumake
        maven
        coreutils
        entr # Run commands when files change
        jq
      ];
  };

  programs = {
    zoxide.enable = true;

    dircolors.enable = true;

    nix-index-database.comma.enable = true;

    nix-index.enable = true;

    htop.enable = true;
    # Used to have custom environment per project.
    # Very useful  to automaticly activate nix-shell when cd'ing to a
    # project folder.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      stdlib = /* sh */ ''
        # PUT this here
        layout_poetry() {
          if [[ ! -f pyproject.toml ]]; then
            log_error 'No pyproject.toml found.  Use `poetry new` or `poetry init` to create one first.'
            exit 2
          fi
        
          local VENV=$(dirname $(poetry run which python))
          export VIRTUAL_ENV=$(echo "$VENV" | rev | cut -d'/' -f2- | rev)
          export POETRY_ACTIVE=1
          PATH_add "$VENV"
        }
      '';
    };

    # A modern replacement for ls.
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      git = true;
    };

    # A modern replacement for cat, with sintax hilghting
    bat = {
      enable = true;
      config = {
        theme = "base16-256";
      };
    };

    jq.enable = true;

    gpg.enable = true;

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
  # home.homeDirectory = pkgs.lib.mkForce "/home/debling";

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