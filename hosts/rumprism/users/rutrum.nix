{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../../modules/home/rutrum.nix
  ];

  me.ui.enable = true;

  home.packages = with pkgs; [
    # hardware utilities
    acpi
    brightnessctl

    # office
    drawio
    libreoffice
  ];
}
