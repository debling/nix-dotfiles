#!/bin/sh

set -ex

nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-facter ./hosts/x220/facter.json \
    --flake .#x220 \
    --target-host root@192.168.0.19 \
    --disk-encryption-keys /tmp/secret.key /tmp/secret.key
        
    # --target-host root@nixos-installer.local \
