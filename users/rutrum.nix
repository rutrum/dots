{ config, pkgs, inputs, ... }: 
let
  terminal = "urxvt";
in {
  
  imports = [
    ./modules/cli
    ./modules/terminal
    ./modules/video-production.nix
    ./modules/office.nix
    ./modules/ssh.nix
    ./modules/games.nix
    ./modules/3d_printing.nix

    (import ./modules/firefox.nix inputs)
  ];

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  bash.terminal = "alacritty"; # should probably find a better spot for this

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rutrum";
  home.homeDirectory = "/home/rutrum";

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

  #home.sessionPath = [
  #  "/home/rutrum/.nix-profile/bin"
  #];

  fonts.fontconfig.enable = true;

  home.file.xmonad = {
    source = ./modules/x/xmonad.hs;
    target = ".config/xmonad/xmonad.hs";
  };

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

  home.packages = with pkgs; [

    # graphical applications
    mullvad-browser
    mullvad-vpn
    thunderbird
    zathura
    flameshot
    gimp
    gnome.simple-scan
    nextcloud-client
    armcord
    sxiv
    pavucontrol
    anki-bin
    font-manager
    bitwarden
    jellyfin-media-player
    calibre
    freetube

    vlc

    # command line utilities

    # container and virtual machines
    distrobox
    # podman
    # podman-compose

    pods # ui for podman

    # hardware utilities
    acpi
    brightnessctl
    psensor

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # my flakes
    # inputs.wasm4
  ];


  services = {
    # flatpak stuff: https://github.com/GermanBread/declarative-flatpak/blob/dev/docs/definition.md
    flatpak = {
      enableModule = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
    };

    # syncthing.enable = true;
    # nixos thing!: syncthing = import ./services/syncthing.nix {};
  };
}
