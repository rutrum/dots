{ config, pkgs, ... }:
{
  services.xserver.desktopManager.gnome.enable = true;

  # Electron and Chromium with Wayland
  #environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = (with pkgs; [
    gnome.gnome-tweaks
  ]) ++ (with pkgs.gnomeExtensions; [
    forge
    wintile-windows-10-window-tiling-for-gnome
  ]);
}
