{ pkgs, config, ... }:
let 
  vpnNamespace = "wg";
  webuiPort = 9009;
in {
  sops.secrets.wireguard_config.owner = "root";

  vpnNamespaces.${vpnNamespace} = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.wireguard_config.path;

    portMappings = [
      { from = webuiPort; to = webuiPort; }
    ];
    accessibleFrom = [
      "192.168.50.0/24"
    ];
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "users";  # not good
    inherit webuiPort;
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    inherit vpnNamespace;
  };
}
