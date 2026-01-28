{
  config,
  pkgs,
  ...
}: {
  services.prometheus = {
    enable = true;
    port = 9090;
    retentionTime = "30d";

    exporters = {
      node = {
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

      smartctl = {
        enable = true;
        port = 9633;
        openFirewall = true;
      };

      nvidia-gpu = {
        enable = true;
        port = 9835;
        openFirewall = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          { targets = ["localhost:9100"]; labels = { host = "rumnas"; }; }
          { targets = ["rumtower:9100"]; labels = { host = "rumtower"; }; }
        ];
      }
      {
        job_name = "smartctl";
        static_configs = [
          { targets = ["localhost:9633"]; labels = { host = "rumnas"; }; }
          { targets = ["rumtower:9633"]; labels = { host = "rumtower"; }; }
        ];
      }
      {
        job_name = "postgres";
        static_configs = [
          { targets = ["rumtower:9187"]; }
        ];
      }
      {
        job_name = "nvidia";
        static_configs = [
          { targets = ["localhost:9835"]; labels = { host = "rumnas"; }; }
          { targets = ["rumtower:9835"]; labels = { host = "rumtower"; }; }
        ];
      }
    ];
  };
}
