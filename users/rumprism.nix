{ config, pkgs, inputs, ... }: 
{
  imports = [
    ./rutrum.nix
    ./modules/terminal
    ./modules/production/3d.nix
    ./modules/production/office.nix
    ./modules/flatpak.nix
    ./modules/firefox.nix
  ];

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

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

  home.packages = with pkgs; [
    # graphical applications
    #mullvad-browser
    mullvad-vpn
    #thunderbird
    zathura
    flameshot
    nextcloud-client
    #armcord
    sxiv
    #pavucontrol
    anki-bin
    bitwarden
    vlc
    prismlauncher # minecraft
    localsend

    # container and virtual machines
    distrobox
    xorg.xhost # for graphical apps

    # hardware utilities
    acpi
    brightnessctl
    psensor

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # my flakes
    # inputs.wasm4
    rustdesk
  ];

  home.stateVersion = "23.05";
}
