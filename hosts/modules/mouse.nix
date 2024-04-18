{ pkgs, ... }:
{
    services.ratbagd.enable = true;
    home.packages = [ pkgs.piper ];
}
