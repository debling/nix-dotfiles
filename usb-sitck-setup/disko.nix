{
  disko.devices = {
    disk.usb = {
      type = "disk";

      content = {
        type = "gpt";
        partitions = {

          bios = {
            size = "2M";
            type = "EF02";
          };

          ESP = {
            size = "300M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/mnt/esp";
            };
          };

          STORAGE = {
            size = "100%-20G-512M";
            content = {
              type = "filesystem";
              format = "exfat";
              mountpoint = "/mnt/storage";
            };
          };

          LUKSKEY = {
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/mnt/key";
            };
          };

          SECRET = {
            size = "20G";
            content = {
              type = "luks";
              name = "usbsecret";
              settings = {
                allowDiscards = true;
                cryptsetupExtraArgs = [
                  "--pbkdf=argon2id"
                ];
              };
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/secret";
              };
            };
          };
        };
      };
    };
  };
}
