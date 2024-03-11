{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true; # for steam
  home.packages = with pkgs; [
    steam
    superTuxKart
    prismlauncher
  ];
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//stable"
  ];
}
