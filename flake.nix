{
  description = "";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Environment/system management
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-themes = {
      url = "github:alacritty/alacritty-theme";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig-overlay";
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
    { nixpkgs
    , darwin
    , nix-on-droid
    , home-manager
    , flake-utils
    , ...
    }@inputs:
    let
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = [
          inputs.android-nixpkgs.overlays.default
          inputs.neovim-nightly-overlay.overlays.default
          inputs.nixpkgs-wayland.overlays.default
          inputs.zig-overlay.overlays.default

          (final: prev: {
            snitch = prev.callPackage overlays/snitch/default.nix { };
            zls = inputs.zls.packages.${prev.system}.default;
            kmonad = inputs.kmonad.packages.${prev.system}.default;

            wbg = prev.wbg.overrideAttrs {
              src = prev.fetchFromGitea {
                domain = "codeberg.org";
                owner = "dnkl";
                repo = "wbg";
                rev = "38417d8172f6c9201495f6388d6d5f6334b19e02";
                hash = "sha256-ikwOVtR5cXZGd2GE/O4ej6cOQZomyEKkPcKe08EtPw0=";
              };
            };
          })
        ];
      };

      username = "debling";

      specialArgs = {
        inherit (inputs) android-nixpkgs alacritty-themes nix-index-database nix-colors;
        mainUser = username;
        colorscheme = inputs.nix-colors.colorschemes.gruvbox-dark-hard;
      };

      homeManagerConfiguration = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs;
      };
    in
    {
      # usb drive
      nixosConfigurations.portable = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        specialArgs = specialArgs;
        modules = [
          "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"

          inputs.disko.nixosModules.disko
          ./hosts/portable/disko.nix

          ./hosts/portable/configuration.nix

          home-manager.nixosModules.home-manager

          {
            nixpkgs = nixpkgsConfig;
            home-manager = homeManagerConfiguration;
          }
        ];
      };

      nixosConfigurations.x220 = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        specialArgs = specialArgs;
        modules = [
          ./hosts/x220/configuration.nix
          home-manager.nixosModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
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

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          config = { allowUnfree = true; };
          system = flake-utils.lib.system.aarch64-darwin;
        };
        extraSpecialArgs = specialArgs;
        modules = [
          ./hosts/pixel-6/nix-on-droid.nix
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (sys: nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);

      packages = flake-utils.lib.eachDefaultSystemMap (sys:
        import nixpkgs (nixpkgsConfig // {
          system = sys;
        })
      );
    };
}
