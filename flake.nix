{
  description = "Home Manager configuration of rutrum";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # colorscheme
    catppuccin.url = "github:catppuccin/nix";

    # declaratively manage flatpaks
    flatpaks.url = "github:GermanBread/declarative-flatpak/stable-v3";

    # mount secrets at runtime from encrypted sops files
    sops-nix.url = "github:Mic92/sops-nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # configure neovim and neovim plugins with nix
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
    };
  };

  outputs = {
    home-manager,
    nixpkgs-stable,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true; # remove this
      overlays = [];
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "dots";
      buildInputs = with pkgs; [
        sops
        alejandra
      ];
    };
    nixosConfigurations."rumprism" = nixpkgs-stable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./hosts/rumprism/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumpi" = nixpkgs-stable.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        (import ./hosts/rumpi/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumtower" = nixpkgs-stable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.flatpaks.nixosModules.declarative-flatpak
        (import ./hosts/rumtower/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumnas" = nixpkgs-stable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.flatpaks.nixosModules.declarative-flatpak
        (import ./hosts/rumnas/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./users/rutrum.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumnas" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./users/rumnas.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumtower" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./users/rumtower.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumprism" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./users/rumprism.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
