# g15 (Dell G15)

Cloned from `hosts/x1-carbon` to bootstrap a Dell G15, to be installed with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere) (same flow
as `hosts/x220`, see the root `nix-anywhere-cmd.sh`).

Configuration: `nixosConfigurations.g15` in `flake.nix` → `hosts/g15/`.

## Before installing

1. **Disk** — `hosts/g15/disko.nix` still points at the x1-carbon NVMe by-id.
   Set `disko.devices.disk.nvme0.device` to the G15's disk, e.g.:

   ```sh
   ls -l /dev/disk/by-id/   # find the NVMe entry
   ```

2. **Hardware report** — `hosts/g15/facter.json` is currently a copy of the
   x1-carbon report so the config evaluates. The install command below
   regenerates it for the actual machine *before* building the system.

3. **Displays (optional, later)** — `hosts/g15/displays.nix` carries the
   x1-carbon/LG EDIDs. Unknown displays fall back to `laptop-only`; replace
   the fingerprints with `autorandr --fingerprint` once the machine is up.

## Install

Run from the **main checkout** (merge the `g15` branch first), not from this
worktree: this machine's Nix cannot evaluate flakes inside linked worktrees
(`git worktree`) — it fails with `getting Git object … object not found
(libgit2 error code = 9)`. Alternatively pass a git URL instead of `.#g15`:

```sh
# LUKS passphrase for the fresh install (used by disko/--disk-encryption-keys)
echo -n 'your-passphrase' > /tmp/secret.key

nix run github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-facter ./hosts/g15/facter.json \
    --flake .#g15 \
    --target-host root@<g15-ip> \
    --disk-encryption-keys /tmp/secret.key /tmp/secret.key
```

The `--generate-hardware-config` flag regenerates `hosts/g15/facter.json`
from the target machine, so remember to commit it after a successful install.

## Notes

- LUKS container name is `g15-crypted` (was `x1-crypted`).
- The host uses home-manager (`home-manager.users.debling = ./home.nix`), not
  nix-maid; only `ryzen` has migrated so far.
- Verify the config evaluates from the repo before installing:

  ```sh
  nix build --no-write-lock-file \
    'git+file:///home/debling/Workspace/debling/nix-dotfiles?ref=g15&shallow=1#nixosConfigurations.g15.config.system.build.toplevel' --no-link
  ```

  (From a normal checkout `nix build .#nixosConfigurations.g15.config.system.build.toplevel --no-link` works the same.)
