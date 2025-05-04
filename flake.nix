{
  description = "";

  inputs = {
    # Package set
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

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
      # submodules are neeed on darwin to pull in karabiner stuff
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
        config = {
          allowBroken = true;
          allowUnfree = true;
          permittedInsecurePackages = [
            "xpdf-4.05"
          ];
        };
        overlays = [
          inputs.android-nixpkgs.overlays.default
          inputs.nixpkgs-wayland.overlays.default
          inputs.zig-overlay.overlays.default
          inputs.nix-alien.overlays.default

          (final: prev: {
            snitch = prev.callPackage overlays/snitch/default.nix { };
            zls = inputs.zls.packages.${prev.system}.default;
            kmonad = inputs.kmonad.packages.${prev.system}.default;
            zen-browser = inputs.zen-browser.packages.${prev.system}.default;
            foot =
              let
                pkgs = import inputs.nixpkgs-master {
                  system = prev.system;
                };
              in
              pkgs.foot;

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

              none-ls-nvim = prev.vimPlugins.none-ls-nvim.overrideAttrs {
                src = prev.fetchFromGitHub {
                  owner = "nvimtools";
                  repo = "none-ls.nvim";
                  rev = "a66b5b9ad8d6a3f3dd8c0677a80eb27412fa5056";
                  hash = "sha256-xMb+wSwTAsI5EEfiyHFUpFDOl4WsK/dDqm8WUKm/L74=";
                };
              };
            };

            karabiner-elements = prev.karabiner-elements.overrideAttrs (old: {
              version = "14.13.0";
              src = prev.fetchurl {
                inherit (old.src) url;
                hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
              };
            });
          })
        ];
      };

      username = "debling";

      specialArgs = {
        inherit (inputs) android-nixpkgs alacritty-themes nix-index-database nix-colors neovim-nightly-overlay;
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
          
          inputs.kmonad.nixosModules.default

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
        specialArgs = specialArgs;
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
