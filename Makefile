.PHONY: switch update

update:
	nix flake update

switch:
	 darwin-rebuild switch --flake .
