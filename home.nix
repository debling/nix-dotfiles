# TODO: separate linux and darwin stuff
# TODO: check programs.lf
# TODO: setup plantuml
{ config, pkgs, nix-index-database, ... }:

let
  customScriptsDir = ".local/bin";
  globalNodePackagesDir = ".local/share/node_packages";
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
      gh

      gnumake
      snitch
      maven

      ### Editors/IDEs
      jetbrains.datagrip
      jetbrains.idea-ultimate
      visualvm

      ### Langs related
      # idris2 # A language with dependent types, XXX: compilation is broken on m1 for now https://github.com/NixOS/nixpkgs/issues/151223
      # ansible
      # clojure # Lisp language with sane concurrency
      cargo
      nodejs
      nodePackages.pnpm
      pipenv

      # (python311.withPackages (ps: with ps; [
      #   pandas
      #   numpy
      #   ipython
      #   # matplotlib
      #   # seaborn
      #   # jupyterlab
      #   # pudb
      #   # torch
      #   # scikit-learn
      # ]))

      poetry

      ### CLI utils
      bitwarden-cli
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
      postgresql_15

      renameutils # adds qmv, and qmc utils for bulk move and copy

      taskwarrior-tui

      # vagrant
      # ouch # Painless compression and decompression for your terminal https://github.com/ouch-org/ouch
      # https://github.com/mic92/nix-update
      nurl # https://github.com/nix-community/nurl
      nix-init # https://github.com/nix-community/nix-init
      oha # HTTP load generator https://github.com/hatoo/oha

      trivy
      cht-sh # https://github.com/chubin/cheat.sh
      # nix-du
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

    sessionPath = [
      "$HOME/${customScriptsDir}"
      "$HOME/${globalNodePackagesDir}/bin"
    ];

    sessionVariables = {
      GRAALVM_HOME = pkgs.graalvm-ce.home;
    };

    file = {
      ${customScriptsDir} = {
        source = ./scripts;
        recursive = true;
      };

      ".npmrc".text = ''
        prefix=~/${globalNodePackagesDir}
        global-bin-dir=~/${globalNodePackagesDir}
      '';

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

      # Stable SDK symlinks
      "SDKs/Java/21".source = pkgs.jdk21.home;
      "SDKs/Java/17".source = pkgs.jdk17.home;
      "SDKs/Java/11".source = pkgs.jdk11.home;
      "SDKs/Java/8".source = pkgs.jdk8.home;
      "SDKs/graalvm".source = pkgs.graalvm-ce.home;
    };

  };

  xdg.configFile = {
    snitch = {
      source = ./config/snitch;
      recursive = true;
    };
  };

  programs = {
    zoxide.enable = true;

    dircolors.enable = true;

    nix-index-database.comma.enable = true;

    nix-index.enable = true;

    vscode = {
      enable = true;
      enableUpdateCheck = false;
      mutableExtensionsDir = true;
      userSettings = {
        "files.autoSave"= "afterDelay";
        "vim.enableNeovim" = true;
        "editor.fontFamily"= "'JetBrains Mono', Menlo, Monaco, 'Courier New', monospace";
        "editor.fontSize" = 14;
        "editor.fontLigatures" = true;
        "workbench.colorTheme" = "Solarized Light";
        "vim.easymotion"= true;
        "vim.incsearch"= true;
        "vim.useSystemClipboard"= true;
        "vim.useCtrlKeys"= true;
        "vim.hlsearch"= true;
        "vim.leader"= "<space>";
        "extensions.experimental.affinity" = {
          "vscodevim.vim" = 1;
        };

      };
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
    eza = {
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
      };
    };

    gpg.enable = true;

    # The true OS
    # emacs = {
    #   enable = true;
    #   package = pkgs.emacs28NativeComp;
    # };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
      };
      enableVteIntegration = true;
      autocd = true;
      history.size = 100000;
      localVariables = {
        TYPEWRITTEN_ARROW_SYMBOL = "➜";
        TYPEWRITTEN_RELATIVE_PATH = "adaptive";
        TYPEWRITTEN_SYMBOL = "$";
      };
      plugins = [
        {
          name = "typewritten";
          src = pkgs.fetchFromGitHub {
            owner = "reobin";
            repo = "typewritten";
            rev = "v1.5.1";
            sha256 = "07zk6lvdwy9n0nlvg9z9h941ijqhc5vvfpbr98g8p95gp4hvh85a";
          };
        }
        { name = "fzf-tab"; src = "${pkgs.zsh-fzf-tab}/share/fzf-tab"; }
      ];
      initExtraBeforeCompInit = ''
        if type brew &>/dev/null
        then
            fpath+="$(brew --prefix)/share/zsh/site-functions"
        fi
      '';
      initExtra = ''
        # Enable editing of the command line in an editor with Ctrl-X Ctrl-E
        autoload -z edit-command-line
        zle -N edit-command-line
        bindkey "^X^E" edit-command-line

        # load module for list-style selection
        # zmodload zsh/complist

        # use the module above for autocomplete selection
        # zstyle ':completion:*' menu yes select

        # now we can define keybindings for complist module
        # you want to trigger search on autocomplete items
        # so we'll bind some key to trigger history-incremental-search-forward function
        # bindkey -M menuselect '?' history-incremental-search-forward

        #### zfzf-tab config
        # disable sort when completing `git checkout`
        zstyle ':completion:*:git-checkout:*' sort false
        # set descriptions format to enable group support
        zstyle ':completion:*:descriptions' format '[%d]'
        # set list-colors to enable filename colorizing
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        # preview directory's content with exa when completing cd
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
        # switch group using `,` and `.`
        zstyle ':fzf-tab:*' switch-group ',' '.'
      '';
    };

    tmux = {
      enable = true;
      escapeTime = 0;
      historyLimit = 10000;
      terminal = "screen-256color";
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
        set -g status-left-length 25
        set -g status-right '%d/%m %H:%M'

        setw -g window-status-current-format '#[bold]#I:#W#[fg=colour9]#F'
        setw -g window-status-format '#[fg=colour250]#I:#W#F'

        # Open new splits in the same directory as the current pane
        bind  %  split-window -h -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"

        bind-key -r f run-shell "tmux neww tmux-sessionizer"
      '';
    };

    gh-dash.enable = true;
    lazygit.enable = true;

    git = {
      enable = true;
      userName = "Denilson dos Santos Ebling";
      userEmail = "d.ebling8@gmail.com";
      delta = {
        enable = true;
        options = {
          syntax-theme = "gruvbox-dark";
        };
      };
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
        push = { autoSetupRemote = true; };
      };
    };
  };


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
