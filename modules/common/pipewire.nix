{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pulsemixer
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
}
