.PHONY: switch update

update:
	nix flake update

switch:
	darwin-rebuild switch --flake .

get-age-key:
	@nix run nixpkgs#bitwarden-cli get password age-key  


iso/build:
	nix build .#nixosConfigurations.live.config.system.build.sdImage

iso/run:
	nix run nixpkgs#qemu -- -enable-kvm -m 2048 -drive format=raw,file=image.img


vm/build:
	nix build .#nixosConfigurations.live.config.system.build.vm
