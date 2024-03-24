{ config, pkgs, inputs, ... }: 
let
  terminal = "urxvt";
in {
  imports = [
    ./modules/cli
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

  home.sessionPath = [
    "/home/rutrum/.nix-profile/bin"
  ];

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    steam
    connamon.cinnamon-common
  ];
}
