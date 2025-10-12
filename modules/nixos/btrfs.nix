{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };

  services.fstrim.enable = true;
}
