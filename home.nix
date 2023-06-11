# TODO: separate linux and darwin stuff
# TODO: check programs.dircolors
# TODO: check programs.hstr
# TODO: check programs.lf
# TODO: check programs.topgrade
# TODO: setup plantuml
{ config, pkgs, nix-index-database, ... }:

let
  customScriptsDir = ".local/bin";
in
{
  imports = [
    ./modules/editors/neovim.nix
    nix-index-database.hmModules.nix-index
  ];

  news.display = "show";

  nix = {
    checkConfig = true;
    settings = {
      experimental-features = "nix-command flakes";
      extra-platforms = "x86_64-darwin aarch64-darwin";
    };
  };

  myModules.editors.neovim.enable = true;

  home = {
    enableNixpkgsReleaseCheck = true;

    packages = with pkgs; [
      gnumake
      snitch
      maven

      ### Editors/IDEs
      jetbrains.datagrip
      jetbrains.idea-ultimate

      ### Langs related
      # idris2 # A language with dependent types, XXX: compilation is broken on m1 for now https://github.com/NixOS/nixpkgs/issues/151223
      # ansible
      # clojure # Lisp language with sane concurrency
      nodejs
      nodePackages.pnpm
      pipenv

      (python311.withPackages (ps: with ps; [
        pandas
        numpy
        ipython
        matplotlib
        seaborn
        jupyterlab
        pudb
      ]))

      ### CLI utils
      #bitwarden-cli
      awscli2
      cloc
      coreutils
      entr # Run commands when files change
      graphviz
      jq
      nixfmt # Formmater for the nix lang
      pandoc
      python310Packages.editorconfig
      rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
      silver-searcher # A faster and more convenient grep. Executable is called `ag`
      terraform
      tree

      ranger

      # hledger
      # hledger-ui
      # hledger-web

      cachix

      # required by doom-emacs
      ripgrep
      fd

      wget
      unrar
      postgresql
      comma

      renameutils # adds qmv, and qmc utils for bulk move and copy

      taskwarrior-tui

      vagrant
      ouch # https://github.com/ouch-org/ouch
      # https://github.com/mic92/nix-update
      # https://github.com/nix-community/nurl
    ] ++ lib.optionals stdenv.isDarwin [
      m-cli # useful macOS CLI commands
    ];

    shellAliases = {
      g = "git";
      e = "emacs -nw";
      v = "vi";
      ni = "nix profile install";
      ns = "nix-shell --pure";
      nsp = "nix-shell -p";
    };

    sessionPath = [ "$HOME/${customScriptsDir}" ];

    file = {
      ${customScriptsDir} = {
        source = ./scripts;
        recursive = true;
      };

      ".ideavimrc".source = ./config/.ideavimrc;
      # Install MacOS applications to the user environment if the targetPlatform is Darwin
      "Applications/Home Manager Apps".source =
        let
          apps = pkgs.buildEnv {
            name = "home-manager-applications";
            paths = config.home.packages;
            pathsToLink = "/Applications";
          };
        in
        "${apps}/Applications";
    };

  };

  xdg.configFile = {
    snitch = {
      source = ./config/snitch;
      recursive = true;
    };
  };

  programs = {
    man = {
      enable = true;
      generateCaches = true;
    };
    nix-index.enable = true;

    vscode = {
      enable = true;
      enableUpdateCheck = false;
      mutableExtensionsDir = true;
    };

    htop.enable = true;

    taskwarrior = {
      enable = true;
      colorTheme = "dark-256";
    };

    # Used to have custom environment per project.
    # Very useful  to automaticly activate nix-shell when cd'ing to a
    # project folder.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # A modern replacement for ls.
    exa = {
      enable = true;
      enableAliases = true;
      git = true;
    };

    # A modern replacement for cat, with sintax hilghting
    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
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
    gh.enable = true;

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
      };
    };

    gpg.enable = true;

    # The true OS
    emacs = {
      enable = true;
      package = pkgs.emacs28NativeComp;
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;
      autocd = true;
      history.size = 100000;
    };

    tmux = {
      enable = true;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "xterm-256color";
      extraConfig = ''
        # Terminal config for TrueColor support
        set -sg terminal-overrides ",*:RGB"

        set -g focus-events on

        set -g mouse on

        set -g set-titles on
        set -g set-titles-string "#S / #W"

        set -g status-style "none,bg=default"
        set -g status-justify centre
        set -g status-bg colour236
        set -g status-right '%d/%m %H:%M'

        setw -g window-status-current-format '#[bold]#I:#W#[fg=colour9]#F'
        setw -g window-status-format '#[fg=colour250]#I:#W#F'

        # Open new splits in the same directory as the current pane
        bind  %  split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
      '';
    };

    git = {
      enable = true;
      userName = "Denilson dos Santos Ebling";
      userEmail = "d.ebling8@gmail.com";
      lfs.enable = true;
      signing = {
        key = "CCBC8AA1AF062142";
        signByDefault = true;
      };
      aliases = {
        co = "checkout";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        st = "status";
        stall = "stash save --include-untracked";
        undo = "reset --soft HEAD^";
      };
      ignores = [ ".dir-locals.el" ".envrc" ".DS_Store" ];
      extraConfig = {
        pull = { rebase = true; };
      };
    };
  };

  # services = { emacs service does not support darwin
  #   emacs = {
  #     enable = true;
  #     client.enable = true;
  #     defaultEditor = true;
  #   };
  # };

  ####
  #### The section bellow is auto-generated by home-manager
  ####

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "debling";
  home.homeDirectory = pkgs.lib.mkForce "/Users/debling";

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
