{
  description = "";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , home-manager
    , flake-utils
    , android-nixpkgs
    , nix-index-database
    , nixos-hardware
    , ...
    }:
    let
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = [
          (final: prev: {
            snitch = prev.callPackage overlays/snitch/default.nix { };
          })

          android-nixpkgs.overlays.default
        ];
      };

      username = "debling";
    in
    {

      # My `nix-darwin` configs
      nixosConfigurations.x220 = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        modules = [
          # Main `nix-darwin` config
          ./hosts/x220/configuration.nix

          nixos-hardware.nixosModules.lenovo-thinkpad-x220

          # `home-manager` module
          home-manager.nixosModules.home-manager

          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              extraSpecialArgs = {
                inherit android-nixpkgs;
                inherit nix-index-database;
              };
            };
          }
        ];
      };

      # My `nix-darwin` configs
      darwinConfigurations."air-m1" = darwin.lib.darwinSystem {
        system = flake-utils.lib.system.aarch64-darwin;
        modules = [
          # Main `nix-darwin` config
          ./hosts/air/configuration.nix

          # `home-manager` module
          home-manager.darwinModules.home-manager

          {
            networking.hostName = "air-m1";
            nixpkgs = nixpkgsConfig;
            users.users.${username}.home = "/Users/${username}";
            # `home-manager` config
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              extraSpecialArgs = {
                inherit android-nixpkgs;
                inherit nix-index-database;
              };
            };
          }
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (sys: nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);
    };
}
