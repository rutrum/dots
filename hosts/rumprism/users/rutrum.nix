{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../../modules/home/rutrum.nix
  ];

  me = {
    gui.enable = true;
  };

  home.packages = with pkgs; [
    # hardware utilities
    acpi
    brightnessctl

    # office
    drawio
    libreoffice
  ];
}
