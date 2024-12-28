{ config, pkgs, mainUser, ... }:
{

  nix = {
    settings.trusted-users = [ "root" mainUser ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    channel.enable = false;
    settings.auto-optimise-store = true;
  };


  system.activationScripts.update-diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "--- diff to current-system"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        echo "---"
      fi
    '';
  };

  system.switch = {
    enable = false;
    enableNg = true;
  };

}
