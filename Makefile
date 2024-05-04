.PHONY: switch update

update:
	nix flake update

switch:
	 darwin-rebuild switch --flake .

get-age-key:
	@nix run nixpkgs#bitwarden-cli get password age-key  
