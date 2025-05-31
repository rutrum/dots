{ pkgs, ... }:
{
  services = {
    calibre-server = {
      enable = true;
      openFirewall = true;
      libraries = [
        "/mnt/barracuda/calibre"
      ];
    };
    calibre-web = {
      enable = true;
      openFirewall = true;
    };
  };
}
