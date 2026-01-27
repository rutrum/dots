{...}: {
  services.caddyProxy.services.adguard.port = 3001;

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = false;
    host = "0.0.0.0";
    port = 3001;
    settings = {
      dns = {
        bind_hosts = [
          "192.168.50.3"  # LAN
          "100.73.14.110" # Tailscale
        ];
        port = 53;
        bootstrap_dns = [
          "9.9.9.9"        # Quad9
          "208.67.222.222" # OpenDNS
        ];
      };
      user_rules = [
        # LAN clients get LAN IP
        "||rum.internal^$dnsrewrite=NOERROR;A;192.168.50.3,client=192.168.50.0/24"
        "||*.rum.internal^$dnsrewrite=NOERROR;A;192.168.50.3,client=192.168.50.0/24"
        # Tailscale clients get Tailscale IP
        "||rum.internal^$dnsrewrite=NOERROR;A;100.73.14.110,client=100.0.0.0/8"
        "||*.rum.internal^$dnsrewrite=NOERROR;A;100.73.14.110,client=100.0.0.0/8"
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [3001]; # web interface
    allowedUDPPorts = [53]; # dns
  };
}
