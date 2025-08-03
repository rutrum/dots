{pkgs, ...}: {
  services = {
    calibre-server = {
      enable = true;
      openFirewall = true;
      libraries = [
        "/mnt/barracuda/calibre"
      ];
      port = 8081;
    };
    calibre-web = {
      enable = true;
      openFirewall = true;
      listen.ip = "0.0.0.0";
    };
  };
}
