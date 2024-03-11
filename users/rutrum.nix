{ config, pkgs, inputs, ... }: 
let
  terminal = "urxvt";
in {
  imports = [
    ./modules/cli
    ./modules/ssh.nix
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

  fonts.fontconfig.enable = true;

  #home.file.xmonad = {
  #  source = ./modules/x/xmonad.hs;
  #  target = ".config/xmonad/xmonad.hs";
  #};

  # Home Directories

  # symlink my music directory
  #home.file.music = {
  #  source = config.lib.file.mkOutOfStoreSymlink "/mnt/barracuda/media/music";
  #  target = "music";
  #};

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
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  home.packages = with pkgs; [];
}
