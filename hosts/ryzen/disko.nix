{
  disko.devices = {
    disk = {
      # NVME — SYSTEM + ACTIVE NIX
      ryzenNvme = {
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
                mountOptions = [ "umask=0077" "defaults" ]
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
                name = "crypt-nvme";
                settings.allowDiscards = true;

                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" ];
                    };

                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "noatime" "compress=zstd:5" "space_cache=v2" ];
                    };

                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "noatime" "compress=zstd:3" "space_cache=v2" "commit=120" ];
                    };

                    "@var" = {
                      mountpoint = "/var";
                      mountOptions = [ "noatime" "compress=zstd:3" ];
                    };
                  };
                };
              };
            };
          };
        };
      };


      # 2TB HDD — ARCHIVE + CACHE
      ryzenHdd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST2000DM008-2FR102_ZFL2HLVJ";
        content = {
          type = "gpt";

          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt-archive";

                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@archive" = {
                      mountpoint = "/archive";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:9"
                        "space_cache=v2"
                        "commit=300"
                      ];
                    };

                    "@binary-cache" = {
                      mountpoint = "/binary-cache";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:9"
                        "space_cache=v2"
                        "commit=300"
                      ];
                    };

                    "@archive-snaps" = {
                      mountpoint = "/archive-snaps";
                      mountOptions = [ "noatime" ];
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
