# nix-dotfiles
System configuration for [nix-darwin](https://github.com/LnL7/nix-darwin) and
NixOS, with user space configuration managed by
[home-manager](https://github.com/nix-community/home-manager).

# Bootraping in MacOS
1. First install [nix](https://nixos.org/download.html#nix-install-macos) in
   your system.

2. After that, since we don't have nix-darwin installed yet, we can
   boostrap the system using the `nix build` command.
   ```sh
   nix build .#darwinConfigurations.phpmb44.system
   ```

3. After the build is complete, we can call nix-darwwin from the
   result symlink that was created by the build
   ```sh
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

3. Done! The configuration is applied into your system, after that,
   you can call `darwin-rebuild` to apply your configuration changes
   directly, without the need to prefix it with `./result/sw/bin`,
   since its now installed into your system environment.

# Configurations
Things that I always use (and recomend), regardless of the machine:

- [Neovim](https://neovim.io/) text editor, you can check my configuration [here](./modules/editors/neovim.nix)
- [Alacrity](https://alacritty.org/), a fast, not bloated terminal, [link to the config](./modules/alacritty)

You can check the home-manager configuration [here](./home.nix). It defines
packages and setups that are available on all machines.

# NixOS on X220
- Wayland using [dwl](https://codeberg.org/dwl/dwl) compositor;
- [dwlb](https://github.com/kolunmi/dwlb) Status bar 

You can check my desktop configuration [here](./modules/desktop/dwl/).

The NixOs configuration can be found [here](./hosts/x220/).


# Nix-Darwin on MacBook Air
- [Yabai](https://github.com/koekeishiya/yabai) for window mangement
- [Janky borders](https://github.com/FelixKratz/JankyBorders), so its you can actually see which window is active at the
movement

The MacOs configuration can be found [here](./hosts/air/).
