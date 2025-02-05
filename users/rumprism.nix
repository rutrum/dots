{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./rutrum.nix
    ./modules/terminal
    ./modules/production/3d.nix
    ./modules/production/office.nix
    ./modules/production/photo.nix
    ./modules/flatpak.nix
    ./modules/databases.nix
    ./modules/networking.nix
    ./modules/browser.nix
    ./modules/fonts.nix
  ];

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  home.packages = with pkgs; [
    # graphical applications
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

    # dont exist yet with nixpkgs, but cargo install works
    #vtracer toml-cli ytop checkexec

    # my flakes
    # inputs.wasm4
    rustdesk
  ];

  home.stateVersion = "23.05";
}
