# TODO: Complete Firefly III setup
# 1. Add ./firefly.nix to imports in hosts/rumnas/configuration.nix
# 2. Add services.postgresql.enable = true; to hosts/rumnas/configuration.nix
# 3. Add secrets to secrets/secrets.yaml:
#      firefly:
#        app-key: "base64:..."  # Generate with: echo "base64:$(head -c 32 /dev/urandom | base64)"
#        importer-token: "..."  # Create in Firefly III: Profile → OAuth → Personal Access Tokens
{
  pkgs,
  config,
  ...
}: let
  dataDir = "/mnt/raid/services/firefly";
  secrets = config.sops.secrets;
in {
  sops.secrets = {
    "firefly/app-key".owner = "firefly-iii";
    "firefly/importer-token".owner = "firefly-iii-data-importer";
  };

  # PostgreSQL database setup
  services.postgresql = {
    ensureDatabases = ["firefly"];
    ensureUsers = [{
      name = "firefly-iii";
      ensureDBOwnership = true;
    }];
  };

  services.firefly-iii = {
    enable = true;

    inherit dataDir;

    settings = {
      APP_ENV = "production";
      APP_KEY_FILE = secrets."firefly/app-key".path;
      APP_URL = "http://firefly.rumnas.local";

      DB_CONNECTION = "pgsql";
      DB_HOST = "/run/postgresql";
      DB_DATABASE = "firefly";
      DB_USERNAME = "firefly-iii";
      # Using socket auth, no password needed
    };
  };

  services.firefly-iii-data-importer = {
    enable = true;

    settings = {
      FIREFLY_III_URL = "http://localhost:8084";
      FIREFLY_III_ACCESS_TOKEN_FILE = secrets."firefly/importer-token".path;
    };
  };

  # Caddy reverse proxy to PHP-FPM sockets
  services.caddyProxy.services.firefly = {
    phpSocket = config.services.phpfpm.pools.firefly-iii.socket;
    root = "${config.services.firefly-iii.package}/public";
  };
  services.caddyProxy.services.firefly-importer = {
    phpSocket = config.services.phpfpm.pools.firefly-iii-data-importer.socket;
    root = "${config.services.firefly-iii-data-importer.package}/public";
  };
}
