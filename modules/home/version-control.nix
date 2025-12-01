{
  programs = {
    jujutsu = {
      enable = true;
      ediff = false;
      settings.user = {
        name = "Denilson dos Santos Ebling";
        email = "d.ebling8@gmail.com";
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Denilson dos Santos Ebling";
          email = "d.ebling8@gmail.com";
        };

        alias = {
          lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
          stall = "stash save --include-untracked";
          # from https://stackoverflow.com/a/30998048
          find-merge = "!sh -c 'commit=$0 && branch=\${1:-HEAD} && (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 -s | uniq -f1 -d | sort -n | tail -1 | cut -f2'";
          show-merge = "!sh -c 'merge=$(git find-merge $0 $1) && [ -n \"$merge\" ] && git show $merge'";
        };

        status = {
          short = true;
          branch = true;
        };
        pull = { rebase = true; };
        push = { autoSetupRemote = true; };
        rebase = { autoStash = true; };
        rerere = { enabled = true; };
        branch = { sort = "-committerdate"; };
      };
      lfs.enable = true;
      signing = {
        key = "CCBC8AA1AF062142";
        signByDefault = true;
      };
      ignores = [ ".dir-locals.el" ".envrc" ".DS_Store" ];
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        syntax-theme = "gruvbox-dark";
        true-color = "always";
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
        };
        git.pagers = [

          {
            colorArg = "always";
            pager = "delta --syntax-theme=gruvbox-dark --paging=never";
          }

        ];
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    gh-dash.enable = true;
  };
}
