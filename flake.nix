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
    , sops-nix
    , disko
    , ...
    }@inputs:
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

      homeManagerConfiguration = {
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${username} = import ./home.nix;
        extraSpecialArgs = {
          inherit (inputs) android-nixpkgs alacritty-themes nix-index-database;
        };
      };
    in
    {

      homeConfigurations."debling" = home-manager.lib.homeManagerConfiguration {
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix

        extraSpecialArgs = {
          inherit (inputs) android-nixpkgs alacritty-themes nix-index-database;
        };
      };

      # usb drive
      nixosConfigurations.live = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        modules = [
          "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"

          disko.nixosModules.disko

          ./disko.nix
          # Main `nix-darwin` config
          ./hosts/x220/configuration.nix


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

          ({lib, ...}: {
            nixpkgs = nixpkgsConfig;
            # `home-manager` config
            home-manager = homeManagerConfiguration;
            networking.hostName = lib.mkForce "removable-nixos"; 
            
            # systemd.services.sshd.wantedBy = lib.mkForce ["multi-user.target"];

            # Much faster than xz
            # isoImage.squashfsCompression = lib.mkDefault "zstd";

            boot.loader.grub.enable = true;
            boot.loader.grub.efiSupport = true;
            boot.loader.grub.device = "/dev/sdb"; # todo : change me once the system booted
            boot.loader.grub.efiInstallAsRemovable = true;
            boot.tmpOnTmpfs = true;

            boot.loader.systemd-boot.enable = false;
            boot.loader.efi.canTouchEfiVariables = false;

          })

        ];
      };


      # My `nix-darwin` configs
      nixosConfigurations.x220 = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        modules = [

          ./hosts/x220/hardware-configuration.nix

          # Main `nix-darwin` config
          ./hosts/x220/configuration.nix

          nixos-hardware.nixosModules.lenovo-thinkpad-x220

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

          {
            networking.hostName = "air-m1";
            nixpkgs = nixpkgsConfig;
            users.users.${username}.home = "/Users/${username}";
            # `home-manager` config
            home-manager = homeManagerConfiguration;
          }
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (sys: nixpkgs.legacyPackages.${sys}.nixpkgs-fmt);
    };
}
