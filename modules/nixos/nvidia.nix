{ pkgs, ... }:
{
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
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
}
