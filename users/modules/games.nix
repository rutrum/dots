{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    superTuxKart
    prismlauncher
    mindustry
    xonotic
  ];
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//stable"
  ];
}
