{
  pkgs,
  config,
  ...
}: let
  vpnNamespace = "wg";

  # Only qBittorrent is VPN-confined — it carries the actual torrent traffic.
  # Prowlarr, Sonarr, and FlareSolverr run on the host network so that
  # FlareSolverr can solve Cloudflare challenges from a real IP, and cookies
  # remain valid for subsequent Prowlarr/Sonarr requests from the same IP.
  vpnServices = {
    qbittorrent.webuiPort = 9009;
  };

  hostServices = {
    prowlarr.webuiPort = 9696;
    sonarr.webuiPort = 8989;
    flaresolverr.webuiPort = 8191;
  };

  vpnServiceNames = builtins.attrNames vpnServices;
  vpnPortList = builtins.map (name: vpnServices.${name}.webuiPort) vpnServiceNames;

  makeWatcher = name: {
    description = "Start ${name} when VPN is available";
    wantedBy = ["wg.service"];
    after = ["wg.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start ${name}.service";
    };
  };

  watchers = builtins.listToAttrs (builtins.map (name: {
      name = "${name}-watcher";
      value = makeWatcher name;
    })
    vpnServiceNames);
in {
  sops.secrets.wireguard_config.owner = "root";

  vpnNamespaces.${vpnNamespace} = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.wireguard_config.path;
    portMappings =
      builtins.map (port: {
        from = port;
        to = port;
      })
      vpnPortList;
    accessibleFrom = ["192.168.50.0/24"];
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = vpnServices.qbittorrent.webuiPort;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = hostServices.flaresolverr.webuiPort;
  };

  # qBittorrent is in the VPN namespace so its proxy host is the veth gateway.
  # All other services run on the host network so no host override is needed.
  services.caddyProxy.services =
    (builtins.mapAttrs (_: cfg: {
        port = cfg.webuiPort;
        host = "192.168.15.1";
      })
      vpnServices)
    // (builtins.mapAttrs (_: cfg: {
        port = cfg.webuiPort;
      })
      hostServices);

  users.users.sonarr.extraGroups = ["media"];
  users.users.qbittorrent.extraGroups = ["media"];

  systemd.tmpfiles.rules = [
    "d /mnt/raid/homes/rutrum/downloads                      0775 rutrum media -"
    "d /mnt/raid/homes/rutrum/downloads/torrents             0775 rutrum media -"
    "d /mnt/raid/homes/rutrum/downloads/torrents/sonarr      0775 rutrum media -"
    "d /mnt/raid/homes/rutrum/downloads/torrents/unsorted    0775 rutrum media -"
  ];

  systemd.services =
    (builtins.mapAttrs (_: _: {
        vpnConfinement = {
          enable = true;
          inherit vpnNamespace;
        };
      })
      vpnServices)
    // watchers;
}
