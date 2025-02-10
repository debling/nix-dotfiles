{ pkgs, config, ... }:

let
  customScriptsDir = ".local/bin";
  globalNodePackagesDir = ".local/share/node_packages";
in
{
  home = {
    packages = with pkgs; [
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
        source = ./../../scripts;
        recursive = true;
      };

      ".npmrc".text = ''
        prefix=~/${globalNodePackagesDir}
        global-bin-dir=~/${globalNodePackagesDir}
      '';

      ".ideavimrc".source = ./../../config/.ideavimrc;

      # Stable SDK symlinks
      "SDKs/Java/current".source = pkgs.jdk;
      "SDKs/Java/11".source = pkgs.jdk11;
      "SDKs/Java/17".source = pkgs.jdk17;
      "SDKs/Java/8".source = pkgs.jdk8;
      # "SDKs/graalvm".source = pkgs.graalvm-ce.home;

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

    gpg.enable = true;

    # The true OS
    emacs = {
      enable = true;
      package = (pkgs.emacsPackagesFor pkgs.emacs30-pgtk).emacsWithPackages (epkgs: with epkgs; [
        nix-mode
        vterm
        treesit-grammars.with-all-grammars
      ]);
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

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

  };

  xdg.configFile."emacs/init.el".source = config.lib.file.mkOutOfStoreSymlink ../../config/emacs/init.el;
}
