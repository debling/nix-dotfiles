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
            bak = {
              size = "100%";
              content = {
                  type = "filesystem";
                  format = "ntfs";
                  mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
