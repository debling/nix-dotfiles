{ pkgs, ...}:

{
  home.packages = with pkgs; [
    cloc
    coreutils
    entr # Run commands when files change
    jq
    killall
    pinentry-tty
    # renameutils # adds qmv, and qmc utils for bulk move and copy
    rlwrap # Utility to have Readline features, like scrollback in REPLs that don`t use the lib
    silver-searcher # A faster and more convenient grep. Executable is called `ag`
    tree
    wget
    imagemagick

    # nix utils
    nurl # helper for creating fetch srcs from urls

    # required by telescope.nvim  
    ripgrep
    fd
    ouch # Painless compression and decompression for your terminal https://github.com/ouch-org/ouch
  ];
}
