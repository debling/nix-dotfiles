.PHONY: default
default: switch

.PHONY: update
update:
	nix flake update

.PHONY: switch
switch:
	ifeq ($(shell uname -s),Darwin)
		darwin-rebuild switch --flake .
	else
		nixos-rebuild switch --flake .
	endif

.PHONY: get-age-key
get-age-key:
	@nix run nixpkgs#bitwarden-cli get password age-key


.PHONY: iso/build
iso/build:
	nix build .#nixosConfigurations.live.config.system.build.sdImage

.PHONY: iso/run
iso/run:
	nix run nixpkgs#qemu -- -enable-kvm -m 2048 -drive format=raw,file=image.img

.PHONY: iso/un
vm/build:
	nix build .#nixosConfigurations.live.config.system.build.vm
