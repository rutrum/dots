{ config, pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.cura.packages.x86_64-linux.default
    #cura #broken for now
  ];
  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];
}
