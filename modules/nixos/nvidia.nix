{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580; # 1050 ti
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Force modesetting initialization
    modesetting.enable = true;
  };

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    cudaPackages.cudatoolkit
    cudaPackages.libcutensor
    cudaPackages.libcublas
    cudaPackages.libcusolver
    cudaPackages.cuda_cudart
  ];

  nixpkgs.config.cudaSupport = true;

  # Manually run the persistence daemon to keep the GPU initialized
  # without relying on the broken powerManagement configuration block.
  systemd.services."nvidia-persistenced" = {
    description = "NVIDIA Persistence Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      Restart = "always";
      PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
      ExecStart = "${config.boot.kernelPackages.nvidia_x11.persistenced}/bin/nvidia-persistenced --verbose";
      ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
    };
  };
}
