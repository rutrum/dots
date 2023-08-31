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

    # eww default bar
    eww-repo = {
      url = "github:elkowar/eww";
      flake = false;
    };

    wasm4.url = "github:rutrum/wasm4-nix";
  };

  outputs = { nixpkgs, home-manager, nixpkgs-stable, eww-repo, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in {
      homeConfigurations."rutrum" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
              inherit pkgs-stable;
              inherit eww-repo;
              wasm4 = inputs.wasm4.defaultPackage.${system};
        };
      };
    };
}
