# nix-dotfiles
System configuration for [nix-darwin](https://github.com/LnL7/nix-darwin) and
NixOS, with user space configuration managed by
[home-manager](https://github.com/nix-community/home-manager).

![Portable NixOS](./docs/screenshot-portablenixos.png)

# Bootstrap Instructions

## MacOS (MacBook Air M1)
1. First install [nix](https://nixos.org/download.html#nix-install-macos) in
   your system.

2. After that, since we don't have nix-darwin installed yet, we can
   bootstrap the system using the `nix build` command.
   ```sh
   nix build .#darwinConfigurations.air-m1.system
   ```

3. After the build is complete, we can call nix-darwin from the
   result symlink that was created by the build
   ```sh
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

4. Done! The configuration is applied into your system, after that,
   you can call `darwin-rebuild` to apply your configuration changes
   directly, without the need to prefix it with `./result/sw/bin`,
   since its now installed into your system environment.

## NixOS (X220)
This setup uses [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) for remote installation and [nixos-facter](https://github.com/nix-community/nixos-facter-modules) for hardware detection.

1. Install NixOS on the target machine
2. Generate hardware config using facter to automatically detect hardware:
   ```sh
   nixos-anywhere --generate-hardware-config nixos-facter ./hosts/x220/facter.json
   ```
3. Apply configuration:
   ```sh
   sudo nixos-rebuild switch --flake .#x220
   ```

## NixOS (X1 Carbon)
Similar to X220, this setup uses nixos-anywhere and nixos-facter for hardware detection.

1. Install NixOS on the target machine
2. Generate hardware config using facter to automatically detect hardware:
   ```sh
   nixos-anywhere --generate-hardware-config nixos-facter ./hosts/x1-carbon/facter.json
   ```
3. Apply configuration:
   ```sh
   sudo nixos-rebuild switch --flake .#x1-carbon
   ```

## NixOS (Portable USB)
This configuration uses [disko](https://github.com/nix-community/disko) for declarative disk management, allowing you to create a portable NixOS system on a USB drive that works on any hardware.

1. Apply configuration to USB drive (disko will handle partitioning and formatting):
   ```sh
   sudo nixos-rebuild switch --flake .#nixos-portable
   ```

The disko configuration in `./hosts/portable/disko.nix` defines the disk layout, making it reproducible across different machines.

## Android (Pixel 6)
This setup uses [nix-on-droid](https://github.com/nix-community/nix-on-droid) to bring Nix package management to Android devices through Termux.

1. Install [nix-on-droid](https://github.com/nix-community/nix-on-droid) following the official setup instructions
2. Apply configuration:
   ```sh
   nix-on-droid switch --flake .
   ```

This allows you to have a consistent development environment on your Android device with the same packages and configurations as your other machines.

# Configurations
Things that I always use (and recommend), regardless of the machine:

- [Neovim](https://neovim.io/) text editor, you can check my configuration [here](./modules/home/neovim/)
- [Foot](https://codeberg.org/dnkl/foot), a fast, lightweight terminal with server mode for instant startup, [link to the config](./modules/nixos/foot.nix)
- [River](https://github.com/riverwm/river), a fast and easy-to-setup dynamic tiling Wayland compositor, [link to the config](./modules/nixos/desktop/river.nix)
- [Alacritty](https://alacritty.org/), a fast, not bloated terminal, [link to the config](./modules/nixos_and_darwin/alacritty.nix)

You can check the home-manager configuration [here](./modules/home/). It defines
packages and setups that are available on all machines.

# Host Details

## NixOS on X220
- Wayland using [dwl](https://codeberg.org/dwl/dwl) compositor
- [dwlb](https://github.com/kolunmi/dwlb) Status bar 

You can check my desktop configuration [here](./modules/nixos/desktop/dwl/).

The NixOS configuration can be found [here](./hosts/x220/).

## NixOS on X1 Carbon
Desktop configuration for ThinkPad X1 Carbon.

The NixOS configuration can be found [here](./hosts/x1-carbon/).

## NixOS on Portable USB
Portable NixOS configuration for USB drive using [disko](https://github.com/nix-community/disko) for declarative disk management. This setup creates a self-contained NixOS system that can boot on any x86_64 machine with all hardware profiles included.

The NixOS configuration can be found [here](./hosts/portable/).

## Nix-Darwin on MacBook Air
- [Yabai](https://github.com/koekeishiya/yabai) for window management
- [Janky borders](https://github.com/FelixKratz/JankyBorders), so you can actually see which window is active at the moment

The MacOS configuration can be found [here](./hosts/air/).

## Nix-on-Droid on Pixel 6
Android configuration using nix-on-droid.

The Android configuration can be found [here](./hosts/pixel-6/).
