{
  modulesPath,
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/C06C-4804";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # from nixos-infect
  #boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];

  # from new nixos-generate-config --show-hardware-config
  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = ["nvme"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9d110546-575b-4559-9507-43eb182eefed";
    fsType = "ext4";
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.hypervGuest.enable = true;
}
