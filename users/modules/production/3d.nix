{ config, pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    orca-slicer
  ];
  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];
}
