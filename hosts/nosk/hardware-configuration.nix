# This is a placeholder hardware configuration.
# You need to generate the actual hardware-configuration.nix on the VPS by running:
#   nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
#
# Then copy it to this location in your dots repository.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Placeholder boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # Adjust for your VPS

  # Placeholder filesystem
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # Swap (adjust as needed)
  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;
}
