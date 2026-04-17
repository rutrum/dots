{
  pkgs,
  config,
  ...
}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    libva
    libva-utils # provides vainfo, vaprobe, etc.
    nvidia-vaapi-driver
    libvdpau
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      nvidia-vaapi-driver
      libvdpau
    ];
  };
}
