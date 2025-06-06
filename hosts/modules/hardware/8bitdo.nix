{
  config,
  pkgs,
  lib,
  ...
}: {
  #hardware.xpadneo.enable = true;
  #services.joycond.enable = true;

  # TODO: manually change some of the axis, see here
  # https://retropie.org.uk/docs/Universal-Controller-Calibration-&-Mapping-Using-xboxdrv/

  # Fix for using Xinput mode on 8bitdo Ultimate C controller
  # Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
  hardware.xpad-noone.enable = true;

  environment.systemPackages = with pkgs; [
    # xboxdrv
    usbutils
  ];

  # Udev rules to start or stop systemd service when controller is connected or disconnected
  #services.udev.extraRules = ''
  #  # May vary depending on your controller model, find product id using 'lsusb'
  #  SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3106", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl start 8bitdo-ultimate-xinput@2dc8:3106"
  #  # This device (2dc8:3016) is "connected" when the above device disconnects
  #  SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{idProduct}=="3016", ATTR{manufacturer}=="8BitDo", RUN+="${pkgs.systemd}/bin/systemctl stop 8bitdo-ultimate-xinput@2dc8:3106"
  #'';
  ## Systemd service which starts xboxdrv in xbox360 mode
  #systemd.services."8bitdo-ultimate-xinput@" = {
  #  unitConfig.Description = "8BitDo Ultimate Controller XInput mode xboxdrv daemon";
  #  serviceConfig = {
  #    Type = "simple";
  #    ExecStart = "${pkgs.xboxdrv}/bin/xboxdrv --detach-kernel-driver --silent --type xbox360 --device-by-id %I --force-feedback --buttonmap A=B,B=A,X=Y,Y=X --axismap lt=y2,y2=x2,x2=lt";
  #  };
  #};
}
