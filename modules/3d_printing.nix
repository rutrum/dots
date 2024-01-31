{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    cura
  ];
  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];
}
