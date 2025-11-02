{ pkgs
, config
, lib
, nix-index-database
, ...
}:

let
  customScriptsDir = ".local/bin";
  globalNodePackagesDir = ".local/share/node_packages";
in
{
  imports = [
    nix-index-database.homeModules.nix-index
    ./emacs.nix
    ./helix.nix
    ./java
  ];

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enable = true;

  programs.newsboat = {
    enable = true;
    autoReload = true;
    urls =
      let
        links = [
          "http://nullprogram.com/feed/"
          "https://planet.emacslife.com/atom.xml"
          "https://cestlaz.zamansky.net/rss.xml"
          "https://lukesmith.xyz/index.xml"
          "http://www.finep.gov.br/component/ninjarsssyndicator/?feed_id=1&format=raw"
          "https://www.openmymind.net/atom.xml"
        ];
        toUrlStruct = url: { url = url; };
      in
      lib.map toUrlStruct links;
    extraConfig = ''
      bind-key j down
      bind-key k up
      bind-key j next articlelist
      bind-key k prev articlelist
      bind-key J next-feed articlelist
      bind-key K prev-feed articlelist
      bind-key G end
      bind-key g home
      bind-key d pagedown
      bind-key u pageup
      bind-key l open
      bind-key h quit
      bind-key a toggle-article-read
      bind-key n next-unread
      bind-key N prev-unread
      bind-key D pb-download
      bind-key U show-urls
      bind-key x pb-delete

      color listnormal cyan default
      color listfocus black yellow standout bold
      color listnormal_unread blue default
      color listfocus_unread yellow default bold
      color info red black bold
      color article white default bold

      highlight all "---.*---" yellow
      highlight feedlist ".*(0/0))" black
      highlight article "(^Feed:.*|^Title:.*|^Author:.*)" cyan default bold
      highlight article "(^Link:.*|^Date:.*)" default default
      highlight article "https?://[^ ]+" green default
      highlight article "^(Title):.*$" blue default
      highlight article "\\[[0-9][0-9]*\\]" magenta default bold
      highlight article "\\[image\\ [0-9]+\\]" green default bold
      highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
      highlight article ":.*\\(link\\)$" cyan default
      highlight article ":.*\\(image\\)$" blue default
      highlight article ":.*\\(embedded flash\\)$" magenta default
    '';
  };

  home = {
    packages = with pkgs; [
      # spelling
      (hunspell.withDicts (d: [
        d.pt_BR
        d.en_US
      ]))

      duckdb

      btop
      cloc
      coreutils
      entr # Run commands when files change
      jq
      killall
      ouch # Painless compression and decompression for your terminal https://github.com/ouch-org/ouch
      zip
      unzip
      pinentry-tty
      rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
      silver-searcher # A faster and more convenient grep. Executable is called `ag`
      tree
      wget
      taskwarrior-tui

      ### media tools
      ffmpeg
      imagemagick
      cmus

      ### nix utils
      nurl # helper for creating fetch srcs from urls
      manix
      nix-output-monitor

      ### required by telescope.nvim
      ripgrep
      fd

      aria2

      hledger
      hledger-ui
      hledger-web
      hledger-interest
      ledger-autosync

      #awscli2
      #ssm-session-manager-plugin
    ];

    sessionPath = [
      "$HOME/${customScriptsDir}"
      "$HOME/${globalNodePackagesDir}/bin"
    ];

    sessionVariables = {
      LEDGER_FILE = "$HOME/Workspace/debling/orgfiles/ledger/journal.hledger";
    };

    file = {
      "${config.programs.taskwarrior.dataLocation}/hooks/on-modify.timewarrior" = {
        executable = true;
        source = "${pkgs.timewarrior.out}/share/doc/timew/ext/on-modify.timewarrior";
      };

      ${customScriptsDir} = {
        source = ./../../scripts;
        recursive = true;
      };

      ".npmrc".text = ''
        prefix=~/${globalNodePackagesDir}
        global-bin-dir=~/${globalNodePackagesDir}
      '';

      ".ideavimrc".source = ./../../config/.ideavimrc;

      ".psqlrc".text = ''
        \pset null '(null)'

        \pset linestyle unicode
        \pset border 2

        -- http://www.postgresql.org/docs/9.3/static/app-psql.html#APP-PSQL-PROMPTING
        -- \set PROMPT1 '%[%033[1m%]%M %n@%/%R%[%033[0m%]%# '

        -- PROMPT2 is printed when the prompt expects more input, like when you type
        -- SELECT * FROM<enter>. %R shows what type of input it expects.
        -- \set PROMPT2 '[more] %R > '

        -- Show how long each query takes to execute
        \timing

        \x auto
        \set VERBOSITY verbose
        \set HISTCONTROL ignoredups
        \set COMP_KEYWORD_CASE upper
      '';
    };

  };

  programs = {
    tealdeer = {
      enable = true;
      settings.update = {
        auto_update = true;
      };
    };

    rbw = {
      enable = true;
      settings = {
        email = "d.ebling8@gmail.com";
        pinentry = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
      };
    };

    htop.enable = true;

    taskwarrior = {
      enable = true;
      colorTheme = "dark-16";
      package = pkgs.taskwarrior3;
    };

    dircolors.enable = true;

    vscode = {
      enable = true;
      mutableExtensionsDir = true;
      package = pkgs.vscodium;
      profiles.default = {
        enableUpdateCheck = false;
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
    };

    irssi = {
      enable = true;
      networks =
        let
          nick = "debling";
          sslOpts = {
            port = 6697;
            autoConnect = true;
          };
        in
        {
          liberachat = {
            inherit nick;
            server = {
              address = "irc.libera.chat";
            }
            // sslOpts;
            channels = {
              nixos.autoJoin = true;
              nixos-dev.autoJoin = true;
              zig.autoJoin = true;
            };
          };
          oftc = {
            inherit nick;
            server = {
              address = "irc.oftc.net";
            }
            // sslOpts;
            channels.home-manager.autoJoin = true;
          };
        };
      extraConfig = ''
        ignores = (
          { level = "JOINS PARTS QUITS NICKS"; }
        );
      '';

    };

    # Used to have custom environment per project.
    # Very useful  to automaticly activate nix-shell when cd'ing to a
    # project folder.
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          load_dotenv = true;
          strict_env = true;
        };
      };
      stdlib = /* sh */ ''
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

    # Terminal fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -n 100'" ];
      fileWidgetCommand = "fd --type f --hidden --strip-cwd-prefix --exclude .git";
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    # JSON query tool, but its mainly used for pretty-printing
    jq.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          controlMaster = "auto";
          controlPersist = "15m";
        };
        "i-*".proxyCommand =
          "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      };
    };
  };

  programs.gpg.enable = true;
  home.file.".gnupg/gpg-agent.conf".text =
    let
      pinentryPkgs = if pkgs.stdenv.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
    in
    ''
      allow-preset-passphrase
      max-cache-ttl 60480000
      default-cache-ttl 60480000
      pinentry-program ${lib.getExe pinentryPkgs}
    '';

  home.file.".clojure/deps.edn".text = /* clojure */ ''
    {:aliases
      {:repl
        {:extra-deps {nrepl/nrepl                {:mvn/version "1.3.1"}
                      cider/cider-nrepl          {:mvn/version "0.57.0"}
                      com.bhauman/rebel-readline {:mvn/version "0.1.5"}}
         :main-opts  ["--eval" "(apply require clojure.main/repl-requires)"
                      "--main" "nrepl.cmdline"
                      "--middleware" "[cider.nrepl/cider-middleware]"
                      "--interactive"
                      "-f" "rebel-readline.main/-main"]}}}
  '';

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    historyLimit = 10000;
    terminal = "tmux";
    sensibleOnTop = false;
    tmuxp.enable = true;
    extraConfig = /* tmux */ ''
      # from  https://yazi-rs.github.io/docs/image-preview/#tmux
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

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
      bind-key -r g run-shell "tmux popup -d '#{pane_current_path}' -E -h 90% -w 90% -T lazygit lazygit"
      bind-key -r y run-shell "tmux popup -d '#{pane_current_path}' -E -h 90% -w 90% -T yazi yazi"
      bind-key -r t run-shell "tmux popup -d '#{pane_current_path}' -E -h 90% -w 90% -T tasks taskwarrior-tui"
    '';
  };

  programs = {
    nushell.enable = true;

    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
      ];
    };
  };
}
