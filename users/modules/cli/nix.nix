{pkgs, ...}: {
  home.packages = with pkgs; [
    nix-tree # look at nix package dependencies
  ];

  programs.nh = {
    enable = true;
    flake = "/home/rutrum/dots";
  };

  nix.registry = {
    # TODO: something was done in 24.05 to add flake inputs as
    # registries, so this may be unncessary...looks like this is
    # at the system level

    # redo nixpkgs to be stable
    nixpkgs = {
      from = {
        type = "indirect";
        id = "nixpkgs";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixos-25.05"; # TODO: make this a variable somewhere
      };
    };

    # add nixpkgs unstable
    unstable = {
      from = {
        type = "indirect";
        id = "unstable";
      };
      to = {
        type = "github";
        owner = "NixOS";
        repo = "nixpkgs";
        ref = "nixos-unstable";
      };
    };
  };
}
