{ pkgs, lib, ... }:
{
  # Nix configuration ------------------------------------------------------------------------------
  users.nix.configureBuildUsers = true;

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix = {
    trustedUsers = ["@admin"];
    extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
  '';
  };

  programs = {
    # Create /etc/bashrc that loads the nix-darwin environment.
    zsh.enable = true;
    nix-index.enable = true;
  };

  # Apps
  environment.systemPackages = with pkgs; [ ];

  # Fonts
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      jetbrains-mono
    ];
  };

  # Keyboard
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
