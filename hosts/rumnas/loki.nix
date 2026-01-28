{
  config,
  pkgs,
  ...
}: {
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
      };

      common = {
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      schema_config.configs = [{
        from = "2024-01-01";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }];

      limits_config = {
        retention_period = "168h"; # 7 days - start conservative, increase if needed
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3100 ];

  # Enable Alloy to ship local logs to Loki
  services.rumAlloy = {
    enable = true;
    lokiUrl = "http://localhost:3100";  # Loki is local on rumnas
  };
}
