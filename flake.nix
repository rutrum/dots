{
  description = "Home Manager configuration of rutrum";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # isolate a single process to use a vpn
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    # colorscheme
    catppuccin.url = "github:catppuccin/nix/release-26.05";

    # declaratively manage flatpaks
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    # mount secrets at runtime from encrypted sops files
    sops-nix.url = "github:Mic92/sops-nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # configure neovim and neovim plugins with nix
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";

    # google fonts and other font sources
    nix-fonts.url = "github:rutrum/nix-fonts";

    # ai spec generation
    openspec.url = "github:Fission-AI/OpenSpec";

    # personal finance management
    pipances.url = "github:rutrum/pipances";

    # autonomous AI agent
    hermes-agent.url = "github:NousResearch/hermes-agent";

    # packages for ai coding agents and tools
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = inputs:
    inputs.blueprint {
      inherit inputs;

      systems = ["x86_64-linux" "aarch64-linux"];

      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
