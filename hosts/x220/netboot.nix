{
  config,
  lib,
  pkgs,
  ...
}:

# Network boot (PXE) of the Fedora Workstation installer on the home LAN.
#
# UEFI x86_64 only. The signed shim + grub are taken straight from the
# Fedora tree, so Secure Boot keeps working. Only the tiny bootloader chain
# travels over TFTP; GRUB then pulls vmlinuz/initrd from nginx over HTTP
# (much faster than serving a ~250 MB initrd over TFTP).
#
# Once Anaconda starts, select "Fedora Workstation" under Software
# Selection to get the Workstation package set. The install itself pulls
# packages from the mirror configured in `mirror` below.
#
# To move to a new Fedora release: bump `fedoraVersion`, make sure the
# mirror carries the matching tree, then re-pin the hashes with:
#   nix store prefetch-file --json <url>   # for each file's `hash`
let
  fedoraVersion = "44";
  serverIp = "10.0.10.1";

  # Out-of-the-box close mirror (UFPR, Curitiba — the only BR mirror the
  # Fedora mirror manager returns for fedora-44/x86_64). Verified in sync
  # with dl.fedoraproject.org at the time of writing.
  mirror = "https://fedora.c3sl.ufpr.br/linux/releases/${fedoraVersion}/Everything/x86_64/os";

  # Fetch a file from the Fedora tree into the store. Nothing mutable lives
  # on disk: both the TFTP and HTTP roots are immutable store paths.
  fetch =
    path: hash:
    pkgs.fetchurl {
      url = "${mirror}/${path}";
      inherit hash;
    };

  # GRUB menu. The default entry boots the local disk so an accidental PXE
  # boot on an already-installed machine does not reinstall it; the install
  # entry must be selected explicitly.
  grubCfg = pkgs.writeText "grub.cfg" ''
    set timeout=10
    set default=1

    menuentry 'Install Fedora ${fedoraVersion} (Everything)' --class fedora --class gnu-linux --class gnu --class os {
      linux (http,${serverIp})/netboot/vmlinuz ip=dhcp inst.repo=${mirror}/ inst.lang=en_US.UTF-8
      initrd (http,${serverIp})/netboot/initrd.img
    }

    menuentry 'Boot from local disk' {
      exit
    }
  '';

  # TFTP root: just the signed Secure Boot chain. The signed grubx64.efi
  # has its prefix baked to /EFI/BOOT, so it reads EFI/BOOT/grub.cfg from
  # the TFTP server.
  tftpRoot = pkgs.runCommandLocal "x220-netboot-tftp" { } ''
    mkdir -p "$out/EFI/BOOT/fonts"
    cp ${fetch "EFI/BOOT/BOOTX64.EFI" "sha256-Vx6la4Vdz3O+xqy2PF3tRMKhkROLyg2M+lqpP2D0b/8="} "$out/EFI/BOOT/BOOTX64.EFI"
    cp ${fetch "EFI/BOOT/grubx64.efi" "sha256-UdKQghzQ3zLeXCRizWMlIna2PvjfxT/aeYVf5RydHkU="} "$out/EFI/BOOT/grubx64.efi"
    cp ${fetch "EFI/BOOT/mmx64.efi" "sha256-+K9ZJ1nIqzO2nEsOdy2lqOKqbQnH29XiTGLIn6X9vQU="} "$out/EFI/BOOT/mmx64.efi"
    cp ${fetch "EFI/BOOT/fonts/unicode.pf2" "sha256-19bkJwDwiV3ibXLzA2gi5WcIk1VC5gyKehCLRd+bCq0="} "$out/EFI/BOOT/fonts/unicode.pf2"
    cp ${grubCfg} "$out/EFI/BOOT/grub.cfg"
  '';

  # Served by nginx at http://${serverIp}/netboot/ for GRUB to load.
  bootFiles = pkgs.runCommandLocal "x220-netboot-http" { } ''
    mkdir -p "$out"
    ln -s ${fetch "images/pxeboot/vmlinuz" "sha256-Szfk5UKmLFgMdReHhIvmyZ5vkI9nEsjG2oVRa41UHeI="} "$out/vmlinuz"
    ln -s ${fetch "images/pxeboot/initrd.img" "sha256-qybVJwuKpd9g6obP3/dnFlMcCVr/I14z2RGXTzUhbUo="} "$out/initrd.img"
  '';
in
{
  services.dnsmasq.settings = {
    enable-tftp = true;
    tftp-root = "${tftpRoot}";

    # Only UEFI x86_64 PXE clients (RFC 4578 option 93 = 7/9) get a boot
    # file. Ordinary DHCP clients never send option 93 and are unaffected.
    dhcp-match = [
      "set:efi-x86_64,option:client-arch,7"
      "set:efi-x86_64,option:client-arch,9"
    ];
    dhcp-boot = [ "tag:efi-x86_64,EFI/BOOT/BOOTX64.EFI" ];
  };

  # dnsmasq's built-in TFTP server. If a transfer ever stalls after the
  # first block (dnsmasq replies from an ephemeral data port), set a fixed
  # `tftp-port-range` and open that UDP range here as well.
  networking.firewall.allowedUDPPorts = [ 69 ];

  # GRUB fetches vmlinuz/initrd over HTTP from here.
  services.nginx.virtualHosts.${serverIp}.locations."/netboot/" = {
    alias = "${bootFiles}/";
  };
}
