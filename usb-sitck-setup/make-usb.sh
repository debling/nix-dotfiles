#!/usr/bin/env bash

set -euo pipefail

DEVICE="$1"
if [ -z "$DEVICE" ]; then
    echo "Usage: sudo nix run .#make-usb -- /dev/sdX"
    exit 1
fi

echo ">>> Applying disk layout"
nix run github:nix-community/disko -- \
    --mode destroy,format,mount \
    --flake ${self}#usb \
    --arg device "\"$DEVICE\""

echo ">>> Installing GRUB (BIOS)"
grub-install \
    --target=i386-pc \
    --boot-directory=/mnt/esp/boot \
    $DEVICE

echo ">>> Installing GRUB (UEFI)"
grub-install \
    --target=x86_64-efi \
    --removable \
    --efi-directory=/mnt/esp \
    --boot-directory=/mnt/esp/boot \
    --modules="part_gpt part_msdos fat exfat ntfs ext2 iso9660 loopback search regexp luks cryptodisk gcry_sha256 gcry_rijndael" \
    $DEVICE

echo ">>> Installing grub.cfg"
install -Dm644 ${./grub.cfg} /mnt/esp/boot/grub/grub.cfg

echo ">>> Creating LUKS key"
mkdir -p /mnt/key
dd if=/dev/random of=/mnt/key/luks.key bs=4096 count=1
chmod 0400 /mnt/key/luks.key

echo ">>> Creating ISO directory"
mkdir -p /mnt/storage/isos

echo ">>> USB setup complete"
