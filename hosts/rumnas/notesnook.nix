{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Notesnook Sync Server — self-contained Podman containers on rumnas
  # Garage is included as a Podman container for S3 storage.

  # Podman network for all notesnook containers
  systemd.services = inputs.self.lib.mkPodmanNetwork config "notesnook";

  # Garage S3 — runs as a Podman container on the notesnook network
  virtualisation.oci-containers.containers.notesnook-garage = {
    image = "dxflrs/garage:v2.3.0";
    hostname = "notesnook-garage";
    ports = [
      "127.0.0.1:3900:3900"
      "127.0.0.1:3901:3901"
      "127.0.0.1:3902:3902"
      "127.0.0.1:3903:3903"
    ];
    volumes = [
      "/mnt/raid/services/garage:/var/lib/garage"
      "/etc/garage/garage.toml:/etc/garage.toml:ro"
    ];
    environmentFiles = [
      "${config.sops.secrets."notesnook/garage-rpc-secret".path}"
    ];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = ["/garage" "status"];
      interval = "30s";
      timeout = "10s";
      retries = 3;
      startPeriod = "30s";
    };
  };

  # Web admin UI for Garage
  virtualisation.oci-containers.containers.garage-webui = {
    image = "ghcr.io/khairul169/garage-webui:latest";
    ports = ["127.0.0.1:3904:8080"];
    environment = {
      GARAGE_URL = "http://notesnook-garage:3900";
      PORT = "3904";
    };
    autoStart = true;
    networks = ["notesnook"];
  };

  # MongoDB
  virtualisation.oci-containers.containers.notesnook-db = {
    image = "mongo:7.0.12";
    hostname = "notesnook-db";
    ports = ["127.0.0.1:27017:27017"];
    volumes = [
      "/mnt/raid/services/notesnook/db:/data/db"
    ];
    environment = {
      MONGO_INITDB_DATABASE = "notesnook";
    };
    command = ["--replSet" "rs0" "--bind_ip_all"];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = [
        "sh"
        "-c"
        "echo 'try { rs.status() } catch (err) { rs.initiate() }; db.runCommand(\"ping\").ok' | mongosh mongodb://localhost:27017 --quiet"
      ];
      interval = "40s";
      timeout = "30s";
      retries = 3;
      startPeriod = "60s";
    };
  };

  # Identity Server
  virtualisation.oci-containers.containers.notesnook-identity = {
    image = "streetwriters/identity:latest";
    ports = ["127.0.0.1:8264:8264"];
    environment = {
      NOTESNOOK_SERVER_PORT = "5264";
      NOTESNOOK_SERVER_HOST = "notesnook-server";
      IDENTITY_SERVER_PORT = "8264";
      IDENTITY_SERVER_HOST = "identity-server";
      SSE_SERVER_PORT = "7264";
      SSE_SERVER_HOST = "sse-server";
      SELF_HOSTED = "1";
      IDENTITY_SERVER_URL = "https://identity.notesnook.rum.internal";
      NOTESNOOK_APP_HOST = "https://app.notesnook.rum.internal";
      MONGODB_CONNECTION_STRING = "mongodb://notesnook-db:27017/identity?replSet=rs0";
      MONGODB_DATABASE_NAME = "identity";
    };
    environmentFiles = [
      "${config.sops.secrets."notesnook/env".path}"
    ];
    dependsOn = ["notesnook-db"];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = ["wget" "--tries=1" "-nv" "-q" "http://localhost:8264/health" "-O-"];
      interval = "40s";
      timeout = "30s";
      retries = 3;
      startPeriod = "60s";
    };
  };

  # Sync Server
  virtualisation.oci-containers.containers.notesnook-server = {
    image = "streetwriters/notesnook-sync:latest";
    ports = ["127.0.0.1:5264:5264"];
    environment = {
      NOTESNOOK_SERVER_PORT = "5264";
      NOTESNOOK_SERVER_HOST = "notesnook-server";
      IDENTITY_SERVER_PORT = "8264";
      IDENTITY_SERVER_HOST = "identity-server";
      SSE_SERVER_PORT = "7264";
      SSE_SERVER_HOST = "sse-server";
      SELF_HOSTED = "1";
      IDENTITY_SERVER_URL = "https://identity.notesnook.rum.internal";
      NOTESNOOK_APP_HOST = "https://app.notesnook.rum.internal";
      MONGODB_CONNECTION_STRING = "mongodb://notesnook-db:27017/?replSet=rs0";
      MONGODB_DATABASE_NAME = "notesnook";
      S3_INTERNAL_SERVICE_URL = "http://notesnook-garage:3900";
      S3_INTERNAL_BUCKET_NAME = "attachments";
      S3_SERVICE_URL = "https://attachments.rum.internal";
      S3_REGION = "us-east-1";
      S3_BUCKET_NAME = "attachments";
    };
    environmentFiles = [
      "${config.sops.secrets."notesnook/env".path}"
    ];
    dependsOn = ["notesnook-identity"];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = ["wget" "--tries=1" "-nv" "-q" "http://localhost:5264/health" "-O-"];
      interval = "40s";
      timeout = "30s";
      retries = 3;
      startPeriod = "60s";
    };
  };

  # SSE Server
  virtualisation.oci-containers.containers.notesnook-sse = {
    image = "streetwriters/sse:latest";
    ports = ["127.0.0.1:7264:7264"];
    environment = {
      NOTESNOOK_SERVER_PORT = "5264";
      NOTESNOOK_SERVER_HOST = "notesnook-server";
      IDENTITY_SERVER_PORT = "8264";
      IDENTITY_SERVER_HOST = "identity-server";
      SSE_SERVER_PORT = "7264";
      SSE_SERVER_HOST = "sse-server";
      SELF_HOSTED = "1";
      IDENTITY_SERVER_URL = "https://identity.notesnook.rum.internal";
      NOTESNOOK_APP_HOST = "https://app.notesnook.rum.internal";
    };
    environmentFiles = [
      "${config.sops.secrets."notesnook/env".path}"
    ];
    dependsOn = ["notesnook-identity" "notesnook-server"];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = ["wget" "--tries=1" "-nv" "-q" "http://localhost:7264/health" "-O-"];
      interval = "40s";
      timeout = "30s";
      retries = 3;
      startPeriod = "60s";
    };
  };

  # Monograph Server
  virtualisation.oci-containers.containers.notesnook-monograph = {
    image = "streetwriters/monograph:latest";
    ports = ["127.0.0.1:6264:3000"];
    environment = {
      NOTESNOOK_SERVER_PORT = "5264";
      NOTESNOOK_SERVER_HOST = "notesnook-server";
      IDENTITY_SERVER_PORT = "8264";
      IDENTITY_SERVER_HOST = "identity-server";
      SSE_SERVER_PORT = "7264";
      SSE_SERVER_HOST = "sse-server";
      SELF_HOSTED = "1";
      IDENTITY_SERVER_URL = "https://identity.notesnook.rum.internal";
      NOTESNOOK_APP_HOST = "https://app.notesnook.rum.internal";
      NODE_ENV = "production";
      HOST = "0.0.0.0";
      API_HOST = "https://api.notesnook.rum.internal";
      PUBLIC_URL = "https://monograph.notesnook.rum.internal";
    };
    environmentFiles = [
      "${config.sops.secrets."notesnook/env".path}"
    ];
    dependsOn = ["notesnook-server"];
    autoStart = true;
    networks = ["notesnook"];
    healthcheck = {
      execCommand = [
        "bun"
        "-e"
        "fetch('http://127.0.0.1:3000/api/health').then(r => { if (!r.ok) process.exit(1); }).catch(() => process.exit(1))"
      ];
      interval = "40s";
      timeout = "30s";
      retries = 3;
      startPeriod = "60s";
    };
  };

  # Autoheal
  virtualisation.oci-containers.containers.notesnook-autoheal = {
    image = "willfarrell/autoheal:latest";
    tty = true;
    restart = "always";
    environment = {
      AUTOHEAL_INTERVAL = "60";
      AUTOHEAL_START_PERIOD = "300";
      AUTOHEAL_DEFAULT_STOP_TIMEOUT = "10";
    };
    volumes = ["/var/run/docker.sock:/var/run/docker.sock"];
    dependsOn = ["notesnook-db"];
    autoStart = true;
    networks = ["notesnook"];
  };

  # Caddy proxy entries
  services.caddyProxy.services = {
    "garage".port = 3900;
    "garage-web".port = 3904;
    "notesnook-api".port = 5264;
    "notesnook-identity".port = 8264;
    "notesnook-sse".port = 7264;
    "notesnook-monograph".port = 6264;
  };

  # Garage config file
  environment.etc."garage/garage.toml".text = ''
    metadata_dir = "/var/lib/garage/meta"
    data_dir = "/var/lib/garage/data"
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

  # Persistence
  systemd.tmpfiles.settings."10-garage-data" = {
    "/mnt/raid/services/garage".d = {
      user = "root";
      group = "root";
      mode = "0770";
    };
  };

  systemd.tmpfiles.settings."10-notesnook-data" = {
    "/mnt/raid/services/notesnook/db".d = {
      user = "root";
      group = "root";
      mode = "0770";
    };
  };

  # SOPS secrets
  sops.secrets."notesnook/garage-rpc-secret" = {
    owner = "root";
  };

  sops.secrets."notesnook/env" = {
    owner = "root";
  };
}
