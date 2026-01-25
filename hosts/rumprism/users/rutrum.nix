{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.homeModules.rutrum
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
