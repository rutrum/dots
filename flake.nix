{
  description = "Home Manager configuration of rutrum";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # for blueprint: I think I must rename this to just nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # isolate a single process to use a vpn
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    # colorscheme
    catppuccin.url = "github:catppuccin/nix/release-25.05";

    # declaratively manage flatpaks
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    # mount secrets at runtime from encrypted sops files
    sops-nix.url = "github:Mic92/sops-nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # configure neovim and neovim plugins with nix
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
  };

  # outputs = inputs: inputs.blueprint { inherit inputs; };

  outputs = {
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
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

        # TODO: use nix https://github.com/cachix/git-hooks.nix
        pre-commit
      ];
    };
    nixosConfigurations."rumprism" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import ./hosts/rumprism/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."saibaman" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        (import ./hosts/saibaman/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumpi" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        (import ./hosts/rumpi/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumtower" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.flatpaks.nixosModules.default
        (import ./hosts/rumtower/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    nixosConfigurations."rumnas" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.flatpaks.nixosModules.default
        (import ./hosts/rumnas/configuration.nix)
      ];
      specialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./modules/home/rutrum.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumnas" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./hosts/rumnas/users/rutrum.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumtower" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./hosts/rumtower/users/rutrum.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    homeConfigurations."rutrum@rumprism" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./hosts/rumprism/users/rutrum.nix
      ];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
