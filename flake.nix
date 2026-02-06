{
  description = "";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    # Package set
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # Modules
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alacritty-themes = {
      url = "github:alacritty/alacritty-theme";
      flake = false;
    };

    nix-colors.url = "github:misterio77/nix-colors";

    flake-utils.url = "github:numtide/flake-utils";

    # overlays
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      # url = "github:nix-community/neovim-nightly-overlay";
      url = "github:Prince213/neovim-nightly-overlay/push-nttnuzwkprtq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls/829f566c1203ab98612577885a85e07eb0101961";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig-overlay";
      };
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      nix-on-droid,
      home-manager,
      flake-utils,
      ...
    }@inputs:
    let
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = {
          allowBroken = true;
          allowUnfree = true;
        };
        overlays = [
          inputs.android-nixpkgs.overlays.default
          inputs.nixpkgs-wayland.overlays.default
          inputs.zig-overlay.overlays.default
          inputs.nix-alien.overlays.default

          (final: prev: {
            snitch = prev.callPackage overlays/snitch/default.nix { };
            zls = inputs.zls.packages.${prev.system}.default;
            zen-browser = inputs.zen-browser.packages.${prev.system}.default;

            wbg = prev.wbg.overrideAttrs {
              src = prev.fetchFromGitea {
                domain = "codeberg.org";
                owner = "dnkl";
                repo = "wbg";
                rev = "38417d8172f6c9201495f6388d6d5f6334b19e02";
                hash = "sha256-ikwOVtR5cXZGd2GE/O4ej6cOQZomyEKkPcKe08EtPw0=";
              };
            };

            vimPlugins = prev.vimPlugins // {
              blink-cmp = inputs.blink-cmp.packages.${prev.system}.blink-cmp;
            };
          })
        ];
      };

      username = "debling";

      specialArgs = {
        inherit (inputs)
          android-nixpkgs
          alacritty-themes
          nix-index-database
          nix-colors
          neovim-nightly-overlay
          ;
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
      nixosConfigurations.nixos-portable = nixpkgs.lib.nixosSystem {
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

      nixosConfigurations.x1-carbon = nixpkgs.lib.nixosSystem {
        system = flake-utils.lib.system.x86_64-linux;
        specialArgs = specialArgs;
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/x1-carbon/disko.nix

          inputs.nixos-facter-modules.nixosModules.facter
          { config.facter.reportPath = ./hosts/x1-carbon/facter.json; }

          ./hosts/x1-carbon/configuration.nix

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
          inputs.disko.nixosModules.disko
          ./hosts/x220/disko.nix
          ./hosts/x220/configuration.nix
          ./modules/nixos/glauth.nix
          inputs.nixos-facter-modules.nixosModules.facter
          {
            config.facter.reportPath =
              let
                reportPath = ./hosts/x220/facter.json;
              in
              if builtins.pathExists reportPath then
                reportPath
              else
                throw "Have you forgotten to run nixos-anywhere with `--generate-hardware-config nixos-facter ${reportPath}`?";
          }
          {
            nixpkgs = nixpkgsConfig;
          }
        ];
      };

      # My `nix-darwin` configs
      darwinConfigurations."air-m1" = darwin.lib.darwinSystem {
        system = flake-utils.lib.system.aarch64-darwin;
        specialArgs = specialArgs;
        modules = [
          # Main `nix-darwin` config
          ./hosts/air/configuration.nix

          # `home-manager` module
          home-manager.darwinModules.home-manager

          {
            networking.hostName = "air-m1";
            nixpkgs = nixpkgsConfig;
            users.knownUsers = [ username ];
            users.users.${username} = {
              uid = 501;
              description = "Denilson S. Ebling";
              home = "/Users/${username}";
            };
            # `home-manager` config
            home-manager = homeManagerConfiguration;
          }
        ];
      };

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs {
          config = {
            allowUnfree = true;
          };
          system = flake-utils.lib.system.aarch64-darwin;
        };
        extraSpecialArgs = specialArgs;
        modules = [
          ./hosts/pixel-6/nix-on-droid.nix
        ];
      };

      formatter = flake-utils.lib.eachDefaultSystemMap (
        sys:
        let
          pkgs = import nixpkgs { system = sys; };
        in
        pkgs.nixfmt-tree
      );

      packages = flake-utils.lib.eachDefaultSystemMap (
        sys:
        import nixpkgs (
          nixpkgsConfig
          // {
            system = sys;
          }
        )
      );
    };
}
