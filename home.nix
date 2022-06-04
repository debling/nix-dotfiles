{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    nixpkgs-fmt

    # Editors/IDEs
    emacs-nox
    jetbrains.idea-ultimate
    jetbrains.datagrip

    # cli utils
    tree
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        syntastic
        vim-multiple-cursors
        vim-nix
        commentary
        polyglot
        gruvbox
        vim-terraform
        vim-terraform-completion
        ctrlp
        neomake
      ];
      extraConfig = ''
        set number relativenumber
        set autoindent
        set smartindent
        set hlsearch
        set smartcase
        set clipboard+=unnamedplus
        set scrolloff=5
        set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab

        let g:gruvbox_contrast_dark='hard'
        colorscheme gruvbox

        if filereadable(expand('~/.config/nvim/init.vim'))
          source ~/.config/nvim/init.vim
        endif
      '';
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      autocd = true;
      enableCompletion = true;
      shellAliases = {
        ni = "nix profile install";
        ns = "nix-shell --pure";
        nsp = "nix-shell -p";
      };
    };

    tmux = {
      enable = true;
      extraConfig = ''
        # Terminal config for TrueColor support
        set -g default-terminal "screen-256color"
        set -ga terminal-overrides ",xterm-256color:Tc"

        # So that escapes register immidiately in vim
        set -sg escape-time 1
        set -g focus-events on

        set -g mouse on

        # extend scrollback
        set-option -g history-limit 5000
      '';
    };
  };



  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "debling";
  # home.homeDirectory = "/Users/debling";

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
