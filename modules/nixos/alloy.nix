# Grafana Alloy log shipper module
# Ships systemd journal logs to a central Loki instance
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rumAlloy;

  alloyConfig = pkgs.writeText "config.alloy" ''
    // Collect systemd journal logs
    loki.source.journal "systemd" {
      forward_to = [loki.write.local.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels = {
        job = "systemd-journal",
      }
    }

    // Relabel journal entries
    loki.relabel "journal" {
      forward_to = []

      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }

      rule {
        source_labels = ["__journal__priority_keyword"]
        target_label  = "level"
      }

      rule {
        source_labels = ["__journal__hostname"]
        target_label  = "host"
      }
    }

    // Send logs to Loki
    loki.write "local" {
      endpoint {
        url = "${cfg.lokiUrl}/loki/api/v1/push"
      }
    }
  '';
in {
  options.services.rumAlloy = {
    enable = lib.mkEnableOption "Alloy log shipper to Loki";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://rumnas:3100";
      description = "URL of the Loki server";
    };
  };

  config = lib.mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = alloyConfig;
    };
  };
}
