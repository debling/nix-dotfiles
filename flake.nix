{
  description = "";

  inputs = {
    # Package sets
    nixpkgs.url = "github:nixos/nixpkgs/22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    /* nixpkgs-unstable.url = "github:NixOS/nixpkgs/22.05"; */

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, darwin, nixpkgs, home-manager, flake-utils, ... }:
    let
      /* overlays = [ (_: _: { }) ]; */
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; allowBroken = true; };
      };

      username = "debling";
    in
    {
      # My `nix-darwin` configs
      darwinConfigurations."phpmb44" = darwin.lib.darwinSystem {
        system = flake-utils.lib.system.aarch64-darwin;
        modules = [
          # Main `nix-darwin` config
          ./configuration.nix

          # `home-manager` module
          home-manager.darwinModules.home-manager

          {
            nixpkgs = nixpkgsConfig;
            users.users.${username}.home = "/Users/${username}";
            # `home-manager` config
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
          }
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (sys: nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);
    };

}
