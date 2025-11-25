{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../modules/home/rutrum.nix

    ./modules/production/3d.nix
    ./modules/production/office.nix
    ./modules/production/photo.nix
    ./modules/flatpak.nix
    ./modules/databases.nix
    ./modules/networking.nix
  ];

  me.ui.enable = true;

  xdg.mimeApps = {
    enable = false;
    defaultApplications = {
      "application/pdf" = "zathura.desktop";
    };
  };

  home.packages = with pkgs; [
    # graphical applications
    mullvad-vpn
    zathura
    flameshot
    nextcloud-client

    # container and virtual machines
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
}
