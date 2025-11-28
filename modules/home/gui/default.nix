{
  pkgs,
  lib,
  config,
  ...
}: {
  options.me = {
    gaming = lib.mkEnableOption "gaming";
  };

  home.packages = with pkgs;
    [
      # add things here
    ]
    ++ (optional config.me.gaming.enable [
      superTuxKart
      mindustry
      xonotic
      lumafly # hallow knight mod manager
      prismlauncher # minecraft launcher
      airshipper # game launcher for veloren
      archipelago # utilities for archipelago servers
    ]);
  services.flatpak.packages = [
    "flathub:app/info.beyondallreason.bar//stable"
  ];
}
