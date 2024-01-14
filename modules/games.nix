{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    superTuxKart
    prismlauncher
  ];
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//master"
  ];
}
