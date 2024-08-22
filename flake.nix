{
  description = "Home Manager configuration of rutrum";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    flatpaks.url = "github:GermanBread/declarative-flatpak/stable";

    nixpkgs-anki-2_1_60 = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "refs/heads/nixpkgs-unstable";
      rev = "8cad3dbe48029cb9def5cdb2409a6c80d3acfe2e";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nixgl.url = "github:guibou/nixGL";

    wasm4.url = "github:rutrum/wasm4-nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # nix/nvim framework
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { home-manager, nixpkgs-stable, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
        overlays = [ inputs.nixgl.overlay ];
      };
    in {
      nixosConfigurations."rumprism" = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ( import ./hosts/rumprism/configuration.nix )
        ];
      };

      nixosConfigurations."rumpi" = nixpkgs-stable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ( import ./hosts/rumpi/configuration.nix )
        ];
      };

      nixosConfigurations."rumtower" = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          inputs.flatpaks.nixosModules.default
          ( import ./hosts/rumtower/configuration.nix )
        ];
        specialArgs = { inherit inputs; };
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
