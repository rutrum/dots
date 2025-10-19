{ pkgs, ... }:
{
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
  };

  # run color script on startup
  # https://gitlab.com/OpenRGBDevelopers/OpenRGB-Wiki/-/blob/stable/User-Documentation/Frequently-Asked-Questions.md#can-i-set-up-openrgb-as-a-systemd-service
  # https://wiki.nixos.org/wiki/OpenRGB
  services.udev.packages = [ pkgs.openrgb ];
  boot.kernelModules = [ "i2c-dev" ];
  hardware.i2c.enable = true;

  systemd.services.set-hardware-rgb = {
    enable = true;
    script = ''
      ${pkgs.openrgb}/bin/openrgb --mode static --color FFFFFF
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wants = [ "openrgb.service" ];
    wantedBy = [ "multi-user.target" ];
  };
}
