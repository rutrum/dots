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
    inputs.flatpaks.homeManagerModules.declarative-flatpak
    inputs.nixvim.homeManagerModules.nixvim
    inputs.catppuccin.homeModules.catppuccin

    ./ui.nix
    ./modules/cli
    ./modules/ssh.nix
  ];

  config = {
    me = {
      terminal = "alacritty";
      ui.enable = false;
    };

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "rutrum";
    home.homeDirectory = "/home/rutrum";

    catppuccin.flavor = "mocha";

    # can this be removed?
    home.sessionPath = [
      "/home/rutrum/.nix-profile/bin"
    ];

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
    };

    home.packages = with pkgs; [
      appimage-run
      distrobox
      pdftk
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
