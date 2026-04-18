{
  disko.devices = {
    disk = {
      x220sata0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDS250G3X0C-00SJG0_2031B4803308";
        content = {
          type = "gpt";

          partitions = {
            esp = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "defaults"
                ];
              };
            };

            swap = {
              size = "16G";
              content = {
                type = "luks";
                name = "crypt-swap";
                settings.allowDiscards = true;
                content.type = "swap";
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-x220sata0";
                settings.allowDiscards = true;

                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };

                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };

                    "@var" = {
                      mountpoint = "/var";
                      mountOptions = [
                        "noatime"
                        "compress=zstd"
                      ];
                    };

                      "@samba" = {
                          mountpoint = "/srv/samba";
                          mountOptions = [ "compress=zstd" "noatime" ];
                      };

                      "@media" = {
                          mountpoint = "/srv/media";
                          mountOptions = [ "compress=no" "noatime" ];
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };

    };
}
