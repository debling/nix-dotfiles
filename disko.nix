{
  disko.devices = {
    disk = {
      main = {
        # When using disko-install, we will overwrite this value from the commandline
        device = "/dev/disk/by-id/usb-WDC_WDS1_20G2G0A-00JH30_20D11E80105D-0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            MBR = {
              type = "EF02"; # for grub MBR
              size = "1M";
              priority = 1; # Needs to be first partition
            };
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "filesystem";
                  format = "f2fs";
                  mountpoint = "/";
                  mountOptions = [
                    # "compress_algorithm=zstd:6"
                    # "compress_chksum"
                    "atgc" "gc_merge"
                    "lazytime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
