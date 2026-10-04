# g15 (Dell G15 5530)

Cloned from `hosts/x1-carbon` and filled in from the actual machine (installed
with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere), same
flow as `hosts/x220`, see the root `nix-anywhere-cmd.sh`).

Configuration: `nixosConfigurations.g15` in `flake.nix` → `hosts/g15/`.

## Machine facts (captured before the install)

- Intel i5-13450HX (16 threads), 16 GB RAM, UEFI, Secure Boot disabled
- Hybrid graphics: Intel UHD (Raptor Lake, `PCI:0:2:0`) + NVIDIA RTX 3050
  6GB Laptop (GA107BM, `PCI:1:0:0`). **The HDMI port is wired to the NVIDIA
  card**; the internal panel (BOE `8FNMF80 B156HAN`, 1920x1080) is on the
  Intel card. `hardware.nvidia.prime.offload` is configured accordingly.
- Single NVMe: ADATA SM2P41C3 512GB
  (`/dev/disk/by-id/nvme-SM2P41C3_NVMe_ADATA_512GB_KO07291HDJHR`), LUKS
  container `g15-crypted` + btrfs + 16G swapfile via `hosts/g15/disko.nix`.
- The factory Manjaro install (and its Windows partitions) was wiped by the
  install.

## Install checklist

1. Target reachable: `ssh zeit@<ip>` must work (pre-install), with
   passwordless sudo (`sudo -n true`) or root ssh available for
   nixos-anywhere.
2. LUKS passphrase: create the install-time key file locally — its content is
   exactly the passphrase you'll type at boot:

   ```sh
   printf 'your-passphrase' > /tmp/secret.key
   ```

3. Run from the **main checkout** (not from `.worktrees/*` — nix on this
   machine can't evaluate flakes inside linked worktrees):

   ```sh
   nix run github:nix-community/nixos-anywhere -- \
       --generate-hardware-config nixos-facter ./hosts/g15/facter.json \
       --flake .#g15 \
       --target-host zeit@10.0.0.109 \
       --disk-encryption-keys /tmp/secret.key /tmp/secret.key
   ```

4. `--generate-hardware-config` overwrites `hosts/g15/facter.json` with the
   real G15 report during the install — commit it afterwards.

## Post-install

- Boot: type the LUKS passphrase from step 2 on the laptop keyboard.
- SSH in as `debling` (key installed by `modules/nixos/users.nix`).
- Check the HDMI output name under the nvidia driver with `xrandr --listproviders`
  / `xrandr -q` (may be `HDMI-1-0`) — if it differs from `HDMI-1`, rename the
  outputs in `hosts/g15/displays.nix` (dual/external-only profiles) and
  `autorandr --fingerprint / --save` for the connected LG UltraWide.
- Verify hybrid graphics: `nvidia-smi`, and offload via
  `nvidia-offload <app>` (installed by `enableOffloadCmd`).
