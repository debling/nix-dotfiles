# Disko layout for g15 (cloned from x1-carbon).
#
# TODO before install: set `device` to the actual disk of the Dell G15. The
# x1-carbon by-id path below is only a placeholder; find the target with
# `ls -l /dev/disk/by-id/` (or let nixos-anywhere regenerate the config).
{
  disko.devices = {
    disk = {
      nvme0 = {
        # NOTE: disko-install overwrites this value from the commandline when
        # used directly; nixos-anywhere reads it verbatim, so confirm it first.
        device = "/dev/disk/by-id/nvme-INTEL_SSDPEKKF256G8L_BTHH8455096S256B:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "g15-crypted";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
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
