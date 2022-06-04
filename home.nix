{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    neovim
    # cli utils
    tree
  ];

  programs = {
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
