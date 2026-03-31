{
  pkgs,
  config,
  ...
}: let
  vpnNamespace = "wg";
  webuiPort = 9009;
in {
  services.caddyProxy.services.qbittorrent = {
    port = webuiPort;
    host = "192.168.15.1";
  };
  sops.secrets.wireguard_config.owner = "root";

  vpnNamespaces.${vpnNamespace} = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.wireguard_config.path;

    portMappings = [
      {
        from = webuiPort;
        to = webuiPort;
      }
    ];
    accessibleFrom = [
      "192.168.50.0/24"
    ];
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    group = "users"; # not good
    inherit webuiPort;
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    inherit vpnNamespace;
  };

  systemd.services.qbittorrent-watcher = {
    description = "Start qbittorrent when VPN is available";
    wantedBy = ["wg.service"];
    after = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start qbittorrent.service";
    };
  };
}
