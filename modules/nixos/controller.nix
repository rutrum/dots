{
  config,
  pkgs,
  lib,
  ...
}: {
  # Fix for using Xinput mode on 8bitdo Ultimate C controller
  # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
  hardware.xpad-noone.enable = true;

  environment.systemPackages = with pkgs; [
    usbutils
    qjoypad
    jstest-gtk
  ];
}
