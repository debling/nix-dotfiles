{ config, pkgs, ... }:

{
  imports = [
    ./modules/editors/neovim.nix
  ];

  modules.editors.neovim.enable = true;
  home = {
    packages = with pkgs; [
      ### Editors/IDEs
      jetbrains.datagrip
      jetbrains.idea-ultimate

      ### Langs related
      # idris2 # A language with dependent types, XXX: compilation is broken on m1 for now https://github.com/NixOS/nixpkgs/issues/151223
      # ansible
      clojure # Lisp language with sane concurrency
      nodejs
      pipenv
      poetry
      #python310Packages.ipython
      #python310Packages.python
      (python310.withPackages (ps: with ps; [pandas numpy ipython]))
      ## Linters
      shellcheck

      ### CLI utils
      #bitwarden-cli
      awscli2
      cloc
      coreutils
      entr # Run commands when files change
      graphviz
      htop
      jq
      nixfmt # Formmater for the nix lang
      pandoc
      python310Packages.editorconfig
      rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
      silver-searcher # A faster and more convenient grep. Executable is called `ag`
      sshfs # Mount remote file systems using SSH
      terraform
      tree

      hledger
      hledger-ui
      hledger-web

      cachix

      # required by doom-emacs
      ripgrep
      fd
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

    file = {
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

  programs = {
    taskwarrior = {
      enable = true;
      colorTheme = "solarized-dark-256";
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
    };

    # Terminal fuzzy finder
    fzf.enable = true;

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
      enableSyntaxHighlighting = true;
      autocd = true;
      enableCompletion = true;
    };

    tmux = {
      enable = true;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "screen-256color";
      extraConfig = ''
        # Terminal config for TrueColor support
        set -ga terminal-overrides ",xterm-256color:Tc"

        # So that escapes register immidiately in vim
        set -sg escape-time 1
        set -g focus-events on

        set -g mouse on
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
