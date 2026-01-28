{
  config,
  pkgs,
  ...
}: {
  # Prometheus server moved to rumnas; exporters here are scraped remotely
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9100;
      openFirewall = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };

    smartctl = {
      enable = true;
      port = 9633;
      openFirewall = true;
    };

    postgres = {
      enable = true;
      port = 9187;
      openFirewall = true;
      dataSourceName = "user=grafana host=/run/postgresql dbname=postgres";
      runAsLocalSuperUser = true;
    };

    nvidia-gpu = {
      enable = true;
      port = 9835;
      openFirewall = true;
    };
  };

  # Ship logs to Loki on rumnas
  services.rumAlloy = {
    enable = true;
    lokiUrl = "http://rumnas:3100";
  };
}
