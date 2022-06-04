# nix-dotfiles
System configuration for [nix-darwin](https://github.com/LnL7/nix-darwin) and
NixOS (soon), with user space configuration managed by
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

# TODO
- [X] Basic userspace config using home-manager;
- [X] Host configuration for my MacBook Pro (M1) using nix-darwin;
- [ ] Host configuration for my Thinkpad X220 machine running NixOS;
- [ ] Migrate my overlays;
- [ ] Complete userspace managed by home-manager;
