{ config, pkgs, inputs, ... }: 
{
  _module.args.inputs = inputs; # this is huge
  imports = [
    ./rutrum.nix

    ./modules/terminal

    ./modules/production/3d.nix
    ./modules/production/video.nix
    ./modules/production/photo.nix
    ./modules/production/office.nix

    ./modules/games.nix
    ./modules/fonts.nix
    ./modules/flatpak.nix
    ./modules/databases.nix
    ./modules/networking.nix

    ./modules/firefox.nix
    ./modules/reading.nix
  ];

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  # for nvidia drivers
  # for home manager?
  nixpkgs.config.allowUnfree = true;


  # symlink my music directory
  #home.file.music = {
  #  source = config.lib.file.mkOutOfStoreSymlink "/mnt/barracuda/media/music";
  #  target = "music";
  #};

  home.packages = let 
    stable-packages = with pkgs; [
      # graphical applications
      mullvad-browser

      thunderbird
      protonmail-bridge-gui

      zathura
      flameshot # x only?
      gnome.simple-scan
      nextcloud-client
      sxiv
      pavucontrol
      anki-bin
      bitwarden
      jellyfin-media-player
      vlc

      # container and virtual machines
      distrobox
      # podman
      # podman-compose

      pods # ui for podman

      # hardware utilities
      acpi
      brightnessctl
      psensor

      rustdesk

      vscodium
      localsend

      pdftk

      # dont exist yet with nixpkgs, but cargo install works
      #vtracer toml-cli ytop checkexec
      discord

      rustdesk
    ];
    unstable-packages = with inputs.nixpkgs-unstable.legacyPackages.x86_64-linux; [
      freetube
      qbittorrent
    ];
  in stable-packages ++ unstable-packages;

  home.stateVersion = "23.05";
}
