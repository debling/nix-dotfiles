{
  programs = {
    git = {
      enable = true;
      userName = "Denilson dos Santos Ebling";
      userEmail = "d.ebling8@gmail.com";
      delta = {
        enable = true;
        options = {
          syntax-theme = "gruvbox-dark";
          true-color = "always";
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
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          nerdFontsVersion = "3";
          border = "hidden";
        };
        git.paging = {
          colorArg = "always";
          pager = "delta --syntax-theme=gruvbox-dark --paging=never";
        };
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    gh-dash.enable = true;
  };
}
