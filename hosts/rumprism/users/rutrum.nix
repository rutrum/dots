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
    # nixpkgs' default `electron` builds Chromium from source; use the
    # prebuilt binary so a rebuild doesn't compile Chromium.
    (drawio.override {electron = pkgs.electron_43-bin;})
    libreoffice
  ];
}
