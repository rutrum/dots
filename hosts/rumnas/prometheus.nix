{
  config,
  pkgs,
  ...
}: {
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "30d";

    exporters.node = {
      enable = true;
      port = 9100;
      openFirewall = true;
      enabledCollectors = [
        "systemd"
        "logind"
        "processes"
        "tcpstat"
      ];
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = ["localhost:9100"]; labels = { host = "rumnas"; }; }
          { targets = ["rumtower:9100"]; labels = { host = "rumtower"; }; }
        ];
      }
    ];
  };
}
