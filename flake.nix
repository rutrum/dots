{
  description = "Home Manager configuration of rutrum";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # include stable version
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-23.11";

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
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # nix/nvim framework
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = { home-manager, nixpkgs-stable, eww-repo, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs-stable {
        inherit system;
        overlays = [ inputs.nixgl.overlay ];
      };
      pkgs-stable = nixpkgs-stable.legacyPackages.${system};
    in {
      nixosConfigurations."rumprism" = pkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ( import ./hosts/rumprism/configuration.nix )
        ];
      };

      nixosConfigurations."rumtower" = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.flatpaks.nixosModules.default
          ( import ./hosts/rumtower/configuration.nix )
        ];
      };

      nixosConfigurations."rumnas" = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.flatpaks.nixosModules.default
          ( import ./hosts/rumnas/configuration.nix )
        ];
      };

      homeConfigurations."rutrum" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          inputs.flatpaks.homeManagerModules.default
          inputs.nixvim.homeManagerModules.nixvim
          ./users/rutrum.nix 
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      homeConfigurations."rutrum@rumnas" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          inputs.flatpaks.homeManagerModules.default
          inputs.nixvim.homeManagerModules.nixvim
          ./users/rutrum_rumnas.nix 
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      homeConfigurations."rutrum@rumtower" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          inputs.flatpaks.homeManagerModules.default
          inputs.nixvim.homeManagerModules.nixvim
          ./users/rutrum_rumtower.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };

      homeConfigurations."rutrum@rumprism" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          inputs.flatpaks.homeManagerModules.default
          inputs.nixvim.homeManagerModules.nixvim
          ./users/rutrum_rumprism.nix
        ];
        extraSpecialArgs = { inherit inputs; };
      };
    };
}
