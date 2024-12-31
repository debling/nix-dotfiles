# TODO: separate linux and darwin stuff
# TODO: check programs.lf
# TODO: setup plantuml
{ config, lib, pkgs, nix-index-database, android-nixpkgs, mainUser, colorscheme, ... }:

let
  customScriptsDir = ".local/bin";
  globalNodePackagesDir = ".local/share/node_packages";
in
{
  imports = [
    ../../modules/editors/neovim.nix
    ../../modules/terminals/alacritty.nix
    ../../modules/terminals/foot.nix
    ../../modules/home/version-control.nix
    ../../modules/home/gtk-qt.nix
    nix-index-database.hmModules.nix-index
    android-nixpkgs.hmModule
  ];

  debling.editors.neovim.enable = true;

  debling.alacritty.enable = true;

  services =
    let
      shouldEnable = pkgs.stdenv.isLinux;
    in
    {
      mako = with colorscheme.palette; {
        enable = shouldEnable;
        defaultTimeout = 10 * 1000;
        layer = "overlay";
        iconPath = "${pkgs.rose-pine-icon-theme}/share/icons/rose-prine-dawn";
        backgroundColor = "#${base00}";
        textColor = "#${base05}";
        borderColor = "#${base0D}";
        progressColor = "#${base02}";
        extraConfig = ''
          [urgency=low]
          background-color=#${base00}
          text-color=#${base0A}
          border-color=#${base0D}

          [urgency=high]
          background-color=#${base00}
          text-color=#${base08}
          border-color=#${base0D}
        '';
      };

      # blueman-applet.enable = shouldEnable;

      # network-manager-applet.enable = shouldEnable;

      mpris-proxy.enable = shouldEnable;
    };

  news.display = "show";

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

  android-sdk = {
    enable = false;

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
    enableNixpkgsReleaseCheck = true;

    packages = with pkgs; [
        pavucontrol
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

        # (python311.withPackages (ps: with ps; [
        #   pandas
        #   numpy
        #   ipython
        #   matplotlib
        #   seaborn
        #   # jupyterlab
        #   pudb
        #   # torch
        #   boto3
        #   scikit-learn
        # ]))
        poetry

        ### CLI utils
        pinentry-tty
        # bitwarden-cli
        # awscli2
        cloc
        coreutils
        entr # Run commands when files change
        graphviz
        jq
        # texlive.combined.scheme-basic
        # pandoc
        # python310Packages.editorconfig
        rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
        silver-searcher # A faster and more convenient grep. Executable is called `ag`
        # terraform
        tree
        killall

        # required by telescope.nvim  
        ripgrep
        fd

        wget
        # unrar
        postgresql_15

        renameutils # adds qmv, and qmc utils for bulk move and copy

        taskwarrior-tui
        timewarrior

        # vagrant
        ouch # Painless compression and decompression for your terminal https://github.com/ouch-org/ouch
        # https://github.com/mic92/nix-update
        nurl # https://github.com/nix-community/nurl
        # nix-init # https://github.com/nix-community/nix-init
        oha # HTTP load generator https://github.com/hatoo/oha

        trivy
        cht-sh # https://github.com/chubin/cheat.sh
        # nix-du

        # https://magic-wormhole.readthedocs.io/en/latest/welcome.html#example
        # magic-wormhole # Send files over the network

        glow
      ];
      

    shellAliases = {
      g = "git";
      e = "emacs -nw";
      v = "nvim";
      ni = "nix profile install";
      ns = "nix-shell --pure";
      nsp = "nix-shell -p";
    };

    sessionPath = [
      "$HOME/${customScriptsDir}"
      "$HOME/${globalNodePackagesDir}/bin"
    ];

    sessionVariables = {
      GRAALVM_HOME = pkgs.graalvm-ce.home;
    };

    file = {
      "${config.programs.taskwarrior.dataLocation}/hooks/on-modify.timewarrior" = {
        executable = true;
        source = "${pkgs.timewarrior.out}/share/doc/timew/ext/on-modify.timewarrior";
      };

      ${customScriptsDir} = {
        source = ../../scripts;
        recursive = true;
      };

      ".npmrc".text = ''
        prefix=~/${globalNodePackagesDir}
        global-bin-dir=~/${globalNodePackagesDir}
      '';

      ".ideavimrc".source = ../../config/.ideavimrc;

      # Stable SDK symlinks
      "SDKs/Java/current".source = pkgs.jdk;
      "SDKs/Java/11".source = pkgs.jdk11;
      "SDKs/Java/17".source = pkgs.jdk17;
      "SDKs/Java/8".source = pkgs.jdk8;
      # "SDKs/graalvm".source = pkgs.graalvm-ce.home;
    };

  };

  xdg.configFile = {
    snitch = {
      source = ../../config/snitch;
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

    dircolors.enable = true;

    nix-index-database.comma.enable = true;

    nix-index.enable = true;

    vscode = {
      enable = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = true;
      package = pkgs.vscodium;
      userSettings = {
        "files.autoSave" = "afterDelay";
        "vim.enableNeovim" = true;
        "editor.fontFamily" = "'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "workbench.colorTheme" = "Solarized Light";
        "vim.easymotion" = true;
        "vim.incsearch" = true;
        "vim.useSystemClipboard" = true;
        "vim.useCtrlKeys" = true;
        "vim.hlsearch" = true;
        "vim.leader" = "<space>";
        "extensions.experimental.affinity" = {
          "vscodevim.vim" = 1;
        };
        "zig.path" = "zig";
        "zig.zls.path" = "zig";
      };
    };

    htop.enable = true;

    taskwarrior = {
      enable = true;
      colorTheme = "dark-16";
      package = pkgs.taskwarrior3;
    };

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

    # Terminal fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -n 100'" ];
      fileWidgetCommand = "fd --type f --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = [ "--preview 'bat --color=always --style=numbers --line-range :100 {}'" ];
    };

    # GitHub's cli tool
    # gh.enable = true;

    java.enable = true;

    # JSON query tool, but its mainly used for pretty-printing
    jq.enable = true;

    ssh = {
      enable = true;
      compression = true;
      controlMaster = "auto";
      controlPersist = "15m";
      matchBlocks = {
        "cvm1" = {
          hostname = "rabapp.cvm.ncsu.edu";
          user = "debling";
        };

        "cvm2" = {
          hostname = "rabapp-test.cvm.ncsu.edu";
          user = "debling";
        };

        "pdsa.aws" = {
          hostname = "ec2-54-232-138-185.sa-east-1.compute.amazonaws.com";
          user = "centos";
          identityFile = "~/.ssh/identities/pdsa-aws.pem";
        };

        "pdsa.review" = {
          hostname = "200.18.45.230";
          user = "admin";
          port = 222;
        };

        "pdsa.dev" = {
          hostname = "200.18.45.231";
          user = "admin";
          port = 222;
        };

        "pdsa.xen" = {
          hostname = "200.18.45.229";
          user = "admin";
        };

        "zeit-ryzen" = {
          hostname = "10.0.0.44";
          user = "debling";
          port = 443;
        };
      };
    };

    gpg.enable = true;

    # The true OS
    # emacs = {
    #   enable = true;
    #   package = if pkgs.stdenv.isDarwin then pkgs.emacs-macport else pkgs.emacs;
    # };

    # yazi = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    # };

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

    gh-dash.enable = true;
  };


  systemd.user.startServices = "sd-switch";


  ####
  #### The section bellow is auto-generated by home-manager
  ####

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = mainUser;
  home.homeDirectory = "/home/debling";

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
