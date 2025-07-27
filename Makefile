ifeq ($(shell uname -s),Darwin)
	REBUILD_CMD=sudo darwin-rebuild
else
	REBUILD_CMD=sudo nixos-rebuild
endif

.PHONY: all
all: update switch

.PHONY: update
update:
	nix flake update

.PHONY: switch
switch:
	$(REBUILD_CMD) switch --flake .

.PHONY: get-age-key
get-age-key:
	@nix run nixpkgs#bitwarden-cli get password age-key

.PHONY: iso/build
iso/build:
	nix build .#nixosConfigurations.live.config.system.build.sdImage

.PHONY: iso/run
iso/run:
	nix run nixpkgs#qemu -- -enable-kvm -m 2048 -drive format=raw,file=image.img

.PHONY: vm/build
vm/build:
	nix build .#nixosConfigurations.live.config.system.build.vm

gc:
	nix-collect-garbage -d
	sudo nix-collect-garbage -d
