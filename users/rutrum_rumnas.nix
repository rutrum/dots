{ config, pkgs, inputs, ... }: 
let
  terminal = "urxvt";
in {
  imports = [
    ./modules/cli
    ./modules/ssh.nix
    ./modules/games.nix
    ./modules/joystick.nix
    ./modules/terminal
    (import ./modules/firefox.nix inputs)
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rutrum";
  home.homeDirectory = "/home/rutrum";

  bash.terminal = "alacritty"; # should probably find a better spot for this

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # for nvidia drivers
  nixpkgs.config.allowUnfree = true;

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
  ];
}
