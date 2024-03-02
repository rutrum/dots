{ config, pkgs, ... }:
{
  # https://nixos.wiki/wiki/Printing
  services.printing.enable = true;
  services.printing.openFirewall = true;

  environment.systemPackages = with pkgs; [
    hplip
  ];

  #services.avahi = {
  #  enabled = true;
  #  nssmdns = true;
  #  openFirewall = true;
  #};
}
