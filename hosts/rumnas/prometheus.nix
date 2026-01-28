{
  config,
  pkgs,
  ...
}: {
  # Sops secrets for AdGuard exporter
  sops.secrets."adguard/user" = {};
  sops.secrets."adguard/pass" = {};

  # Generate environment file for the container from sops secrets
  sops.templates."adguard-exporter.env".content = ''
    ADGUARD_SERVERS=http://host.containers.internal:3001
    ADGUARD_USERNAMES=${config.sops.placeholder."adguard/user"}
    ADGUARD_PASSWORDS=${config.sops.placeholder."adguard/pass"}
    INTERVAL=30s
  '';

  # AdGuard Home exporter (no native NixOS module, so containerized)
  # Uses host.containers.internal to reach AdGuard on the host
  virtualisation.oci-containers.containers.adguard-exporter = {
    image = "ghcr.io/henrywhitaker3/adguard-exporter:latest";
    ports = ["9618:9618"];
    environmentFiles = [
      config.sops.templates."adguard-exporter.env".path
    ];
    extraOptions = ["--add-host=host.containers.internal:host-gateway"];
    autoStart = true;
  };
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

      blackbox = {
        enable = true;
        port = 9115;
        openFirewall = true;
        configFile = pkgs.writeText "blackbox.yml" ''
          modules:
            icmp:
              prober: icmp
              timeout: 5s
            http_2xx:
              prober: http
              timeout: 5s
        '';
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
      # Blackbox ICMP ping monitoring
      {
        job_name = "blackbox-icmp";
        metrics_path = "/probe";
        params = { module = ["icmp"]; };
        static_configs = [
          { targets = ["192.168.50.1" "1.1.1.1" "8.8.8.8"]; }
        ];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "localhost:9115"; }
        ];
      }
      # Blackbox HTTP service health checks
      {
        job_name = "blackbox-http";
        metrics_path = "/probe";
        params = { module = ["http_2xx"]; };
        static_configs = [
          { targets = [
              "http://jellyfin.rum.internal"
              "http://immich.rum.internal"
              "http://hass.rum.internal"
              "http://grafana.rum.internal"
              "http://prometheus.rum.internal"
              "http://adguard.rum.internal"
              "http://mealie.rum.internal"
              "http://freshrss.rum.internal"
              "http://nocodb.rum.internal"
              "http://openwebui.rum.internal"
            ];
          }
        ];
        relabel_configs = [
          { source_labels = ["__address__"]; target_label = "__param_target"; }
          { source_labels = ["__param_target"]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "localhost:9115"; }
        ];
      }
      # AdGuard Home DNS statistics
      {
        job_name = "adguard";
        static_configs = [
          { targets = ["localhost:9618"]; }
        ];
      }
    ];
  };
}
