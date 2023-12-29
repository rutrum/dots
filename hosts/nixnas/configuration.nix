{ config, pkgs, ... }:
let 
  hostname = "nixnas";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "America/Indiana/Indianapolis";
}
