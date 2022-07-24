.PHONY: switch update

update:
	nix flake update

switch: update
	 darwin-rebuild switch --flake .
