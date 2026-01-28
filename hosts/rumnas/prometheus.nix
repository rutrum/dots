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

    # Alertmanager configuration
    alertmanager = {
      enable = true;
      port = 9093;
      configuration = {
        global = {
          resolve_timeout = "5m";
        };
        route = {
          receiver = "ntfy";
          group_by = ["alertname" "host"];
          group_wait = "30s";
          group_interval = "5m";
          repeat_interval = "4h";
        };
        receivers = [
          {
            name = "ntfy";
            webhook_configs = [
              {
                url = "http://localhost:8888/alertmanager";
                send_resolved = true;
              }
            ];
          }
        ];
      };
    };

    alertmanagers = [
      {
        static_configs = [
          { targets = ["localhost:9093"]; }
        ];
      }
    ];

    # Alert rules
    rules = [
      (builtins.toJSON {
        groups = [
          {
            name = "hardware";
            rules = [
              {
                alert = "HostDown";
                expr = "up == 0";
                for = "2m";
                labels = { severity = "critical"; };
                annotations = {
                  summary = "Host {{ $labels.host }} is down";
                  description = "{{ $labels.job }} on {{ $labels.instance }} has been down for more than 2 minutes.";
                };
              }
              {
                alert = "DiskSpaceLow";
                expr = "(1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|overlay\"} / node_filesystem_size_bytes{fstype!~\"tmpfs|overlay\"}) > 0.85";
                for = "5m";
                labels = { severity = "warning"; };
                annotations = {
                  summary = "Disk space low on {{ $labels.host }}";
                  description = "Filesystem {{ $labels.mountpoint }} on {{ $labels.host }} is over 85% full.";
                };
              }
              {
                alert = "DiskHealthBad";
                expr = "smartctl_device_smart_healthy != 1";
                for = "1m";
                labels = { severity = "critical"; };
                annotations = {
                  summary = "SMART health check failed";
                  description = "Disk {{ $labels.device }} on {{ $labels.host }} is reporting unhealthy SMART status.";
                };
              }
              {
                alert = "HighMemoryUsage";
                expr = "(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) > 0.9";
                for = "5m";
                labels = { severity = "warning"; };
                annotations = {
                  summary = "High memory usage on {{ $labels.host }}";
                  description = "Memory usage on {{ $labels.host }} is above 90%.";
                };
              }
              {
                alert = "ServiceDown";
                expr = "probe_success == 0";
                for = "2m";
                labels = { severity = "critical"; };
                annotations = {
                  summary = "Service {{ $labels.instance }} is down";
                  description = "HTTP probe to {{ $labels.instance }} has been failing for more than 2 minutes.";
                };
              }
            ];
          }
        ];
      })
    ];

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
