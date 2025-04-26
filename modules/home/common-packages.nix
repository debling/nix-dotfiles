{ pkgs, config, lib, ... }:


let
  customScriptsDir = ".local/bin";
  globalNodePackagesDir = ".local/share/node_packages";
in
{
  imports = [
    ../editors/emacs.nix
    ./java
  ];

  home = {
    packages = with pkgs; [
      # spelling
      (nunspellWithDicts [hunspellDicts.pt_BR hunspellDicts.en_US])
      (hunspellWithDicts [hunspellDicts.pt_BR hunspellDicts.en_US])

      btop
      cloc
      coreutils
      entr # Run commands when files change
      jq
      killall
      ouch # Painless compression and decompression for your terminal https://github.com/ouch-org/ouch
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
    ];


    shellAliases = {
      g = "git";
      v = "nvim";
    };

    sessionPath = [
      "$HOME/${customScriptsDir}"
      "$HOME/${globalNodePackagesDir}/bin"
    ];

    sessionVariables = {
      GRAALVM_HOME = pkgs.graalvm-ce.home;
      LEDGER_FILE = "$HOME/Workspace/debling/orgfiles/journal.hledger";
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

      # TODO: migrate to common
      ".psqlrc".text = ''
        \pset null '(null)'

        \pset linestyle unicode
        \pset border 2

        -- http://www.postgresql.org/docs/9.3/static/app-psql.html#APP-PSQL-PROMPTING
        \set PROMPT1 '%[%033[1m%]%M %n@%/%R%[%033[0m%]%# '
        
        -- PROMPT2 is printed when the prompt expects more input, like when you type
        -- SELECT * FROM<enter>. %R shows what type of input it expects.
        \set PROMPT2 '[more] %R > '

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

    nix-index-database.comma.enable = true;

    nix-index.enable = true;

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
            } // sslOpts;
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
            } // sslOpts;
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

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

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
}
