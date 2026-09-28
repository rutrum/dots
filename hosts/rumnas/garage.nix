{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Garage S3 — rumnas-wide object storage for notesnook and future services

  services.garage = {
    enable = true;
    package = pkgs.garage;

    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/mnt/raid/services/garage/data";
    };

    environmentFile = config.sops.secrets."notesnook/garage-rpc-secret".path;

    logLevel = "warn";
  };

  # Override auto-generated garage.toml with full config including all sections
  environment.etc."garage.toml".text = ''
    metadata_dir = "/var/lib/garage/meta"
    data_dir = "/mnt/raid/services/garage/data"
    db_engine = "lmdb"
    replication_factor = 1
    consistency_mode = "consistent"

    [rpc]
    rpc_bind_addr = "[::]:3901"
    rpc_public_addr = "127.0.0.1:3901"

    [s3_api]
    s3_region = "us-east-1"
    api_bind_addr = "[::]:3900"
    root_domain = ".s3.garage"

    [s3_web]
    bind_addr = "[::]:3902"
    root_domain = ".web.garage"

    [admin]
    api_bind_addr = "[::]:3903"
  '';

  # Web admin UI for Garage (host network to reach Garage at localhost)
  virtualisation.oci-containers.containers.garage-webui = {
    image = "ghcr.io/khairul169/garage-webui:latest";
    environment = {
      GARAGE_URL = "http://127.0.0.1:3900";
      PORT = "3904";
    };
    extraOptions = ["--network=host"];
    autoStart = true;
  };

  # Caddy proxy entries
  services.caddyProxy.services = {
    "garage".port = 3900;
    "garage-web".port = 3904;
  };

  # Podman network for future notesnook containers
  systemd.services = inputs.self.lib.mkPodmanNetwork config "notesnook";

  # Persistence
  systemd.tmpfiles.settings."10-garage-data" = {
    "/mnt/raid/services/garage".d = {
      user = "root";
      group = "root";
      mode = "0770";
    };
  };

  sops.secrets."notesnook/garage-rpc-secret" = {
    owner = "root";
  };
}
