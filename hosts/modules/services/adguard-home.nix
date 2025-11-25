{...}: {
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true; # change later when I know what I'm doing
  };

  networking.firewall = {
    allowedTCPPorts = [3001]; # web interface
    allowedUDPPorts = [53]; # dns
  };
}
