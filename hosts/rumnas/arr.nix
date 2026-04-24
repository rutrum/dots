{
  pkgs,
  config,
  ...
}: let
  vpnNamespace = "wg";

  services = {
    qbittorrent.webuiPort = 9009;
    prowlarr.webuiPort = 9696;
    sonarr.webuiPort = 8989;
  };

  serviceNames = builtins.attrNames services;
  portList = builtins.map (name: services.${name}.webuiPort) serviceNames;

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
    serviceNames);
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
      portList;
    accessibleFrom = ["192.168.50.0/24"];
  };

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = services.qbittorrent.webuiPort;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.caddyProxy.services =
    builtins.mapAttrs (name: cfg: {
      port = cfg.webuiPort;
      host = "192.168.15.1";
    })
    services;

  systemd.services =
    (builtins.mapAttrs (name: _: {
        vpnConfinement = {
          enable = true;
          inherit vpnNamespace;
        };
      })
      services)
    // watchers;
}
