{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # This is the base rutrum config that all other rutrum_system configs include.
  # It is also a standalone headless user configuration (such as raspberry pi servers
  # or WSL) which means there shouln't be any GUI applications

  imports = [
    inputs.flatpaks.homeModules.default
    inputs.nixvim.homeManagerModules.nixvim
    inputs.catppuccin.homeModules.catppuccin

    ../../users/ui.nix
    ./cli
    ./gui
  ];

  config = {
    me = {
      ui.enable = false;
    };

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
      username = "rutrum";
      homeDirectory = "/home/rutrum";

      shell.enableFishIntegration = true;
    };

    services = {
      # flatpak stuff: https://github.com/GermanBread/declarative-flatpak/blob/dev/docs/definition.md

      flatpak = {
        enable = true;
        remotes = {
          "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        };
      };
    };

    catppuccin.flavor = "mocha";

    xdg.userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/desktop";
      documents = null;
      download = "${config.home.homeDirectory}/downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = null;
      publicShare = null;
      templates = null;
      videos = null;
    };

    programs = {
      home-manager.enable = true;
      ssh.enable = true;

      nh = {
        enable = true;
        flake = "/home/rutrum/dots";
      };
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

    home.packages = with pkgs; [
      appimage-run
      distrobox
      pdftk

      # networking
      dig
      dnsutils
      lftp # ftps client

      # nix
      nix-tree # look at nix package dependencies

      # fonts
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.iosevka-term-slab
      noto-fonts-emoji
    ];

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "23.05";
  };
}
