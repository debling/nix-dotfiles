{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  home-manager.sharedModules = [
    {
      # this enable the playback controls of bluetooth headsets
      services.mpris-proxy.enable = true;
    }
  ];
}
