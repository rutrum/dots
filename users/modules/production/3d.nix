{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    #cura #TODO: broken, consider unstable
  ];
  services.flatpak.packages = [
    "flathub-beta:app/org.openscad.OpenSCAD//beta"
  ];
}
