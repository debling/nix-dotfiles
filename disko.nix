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
                mountOptions = [ "umask=0077" ];
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
                  extraArgs = [
                    # Extends node bitmap
                    # this will increaase the number of inodes, to prevent the
                    # case of the drive have free space, but the disk is full
                    # bcs theres no inode lefs
                    # see: https://lore.kernel.org/all/CAF_dkJB%3d2PAqes+41xAi74Z3X0dSjQzCd9eMwDjpKmLD9PBq6A@mail.gmail.com/T/
                    "-i"

                    # Flags
                    "-O"
                    # - inode_checksum and sb_checksum to help detect
                    # corruption, both require the extra_attr flag to be
                    # enabled as well
                    # - compression, enable transparent compression, also
                    # requires the extra_attr
                    "extra_attr,inode_checksum,sb_checksum,compression"
                  ];
                  mountOptions = [
                    # tells F2FS to use zstd for compression at level 6, which
                    # should give pretty good compression ratio.
                    "compress_algorithm=zstd:6"
                    # tells the filesystem to verify compressed blocks with a
                    # checksum (to avoid corruption)
                    "compress_chksum"

                    # Enable better garbage collector, and enable some
                    # foreground garbage collections to be asynchronous
                    "atgc"
                    "gc_merge"

                    # Do not synchronously update access or modification times.
                    # Improves IO performance and flash durability. 
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
