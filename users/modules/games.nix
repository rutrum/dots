{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true; # for steam
  home.packages = with pkgs; [
    steam
    superTuxKart
    prismlauncher
    mindustry-wayland
  ];
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//stable"
  ];
}
