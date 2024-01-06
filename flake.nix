{
  description = "Home Manager configuration of rutrum";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # include stable version
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-23.05";

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    nixpkgs-anki-2_1_60 = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "8cad3dbe48029cb9def5cdb2409a6c80d3acfe2e";
    };

    # eww default bar
    eww-repo = {
      url = "github:elkowar/eww";
      flake = false;
    };

    nixgl.url = "github:guibou/nixGL";

    wasm4.url = "github:rutrum/wasm4-nix";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixpkgs-stable, eww-repo, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ inputs.nixgl.overlay ];
      };
      #pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in {
      nixosConfigurations."rumprism" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ( import ./hosts/rumprism/configuration.nix )
        ];
      };

      nixosConfigurations."rumtower" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ( import ./hosts/rumtower/configuration.nix )
        ];
      };

      homeConfigurations."rutrum" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ 
          inputs.flatpaks.homeManagerModules.default
          ./home.nix 
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
              inherit pkgs-stable;
              inherit eww-repo;
              wasm4 = inputs.wasm4.defaultPackage.${system};
              firefox-addons = inputs.firefox-addons.packages.${system};
              anki-bin = inputs.nixpkgs-anki-2_1_60.legacyPackages.${system}.anki-bin;
        };
      };
    };
}
