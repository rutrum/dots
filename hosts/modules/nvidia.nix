{ pkgs, config, ... }:
{
  services.xserver.videoDrivers = ["nvidia"];

  hardware.opengl = { enable = true; driSupport = true; driSupport32Bit = true; };
  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  nixpkgs.config.allowUnfree = true;
}
