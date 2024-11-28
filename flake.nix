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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    alacritty-themes = {
      url = "github:alacritty/alacritty-theme";
      flake = false;
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # zig-overlay.follows = "zig-overlay";
      };
    };

    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    { self
    , darwin
    , nixpkgs
    , home-manager
    , flake-utils
    , ...
    }@inputs:
    let
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = [
          inputs.zig-overlay.overlays.default

          (final: prev: {
            snitch = prev.callPackage overlays/snitch/default.nix { };
            zls = inputs.zls.packages.${prev.system}.default;
            kmonad = inputs.kmonad.packages.${prev.system}.default;
          })

          inputs.android-nixpkgs.overlays.default

          inputs.nixpkgs-wayland.overlays.default
        ];
      };

      username = "debling";

      specialArgs = {
        inherit (inputs) android-nixpkgs alacritty-themes nix-index-database nix-colors;
        mainUser = username;
        colorscheme = inputs.nix-colors.colorschemes.tomorrow-night;
      };

      homeManagerConfiguration = {
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = import ./home.nix;
        extraSpecialArgs = specialArgs;
      };
    in
    {

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix

        extraSpecialArgs = specialArgs;
      };

      # usb drive
      nixosConfigurations.live = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        modules = [
          "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"

          inputs.disko.nixosModules.disko

          ./disko.nix
          ./hosts/portable/configuration.nix
          ./modules/desktop/dwl

          {
            virtualisation.vmVariant = {
              # following configuration is added only when building VM with build-vm
              virtualisation = {
                memorySize = 2048;
                cores = 2;
                graphics = true;
              };
            };

            environment.sessionVariables = {
              # Nedded to make wlroots work with no hw accell
              WLR_RENDERER_ALLOW_SOFTWARE = 1;
            };
          }

          # `home-manager` module
          home-manager.nixosModules.home-manager

          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager = homeManagerConfiguration;
          }

        ];
      };


      # My `nix-darwin` configs
      nixosConfigurations.x220 = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        specialArgs = specialArgs;
        modules = [
          ./hosts/x220/hardware-configuration.nix

          # Main `nix-darwin` config
          ./hosts/x220/configuration.nix

          ./modules/desktop/dwl
          ./modules/common/fonts.nix
          ./modules/common/bluetooth.nix
          ./modules/nixos/containers.nix

          # `home-manager` module
          home-manager.nixosModules.home-manager

          {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager = homeManagerConfiguration;
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

          ({ pkgs, ... }: {
            networking.hostName = "air-m1";
            nixpkgs = nixpkgsConfig;
            users.knownUsers = [ username ];
            users.users.${username} = {
              uid = 501;
              description = "Denilson S. Ebling";
              home = "/Users/${username}";
              shell = pkgs.fish;
            };
            # `home-manager` config
            home-manager = homeManagerConfiguration;
          })
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (sys: nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);
    };
}
