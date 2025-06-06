{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    superTuxKart
    mindustry
    xonotic
    lumafly # hallow knight mod manager
    prismlauncher # minecraft launcher
    airshipper # game launcher for veloren
    archipelago # utilities for archipelago servers
  ];
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//stable"
  ];
}
