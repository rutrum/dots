{config, ...}: let
  secrets = config.sops.secrets;
in {
  services.caddyProxy.services.forgejo.port = 3333;

  services.postgresql = {
    ensureDatabases = ["forgejo"];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
    ];
  };

  services.forgejo = {
    enable = true;
    stateDir = "/mnt/raid/services/forgejo";
    database = {
      type = "postgres";
      host = "/run/postgresql";
      name = "forgejo";
      user = "forgejo";
    };
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "forgejo.rum.internal";
        ROOT_URL = "http://forgejo.rum.internal/";
        HTTP_PORT = 3333;
        SSH_DOMAIN = "forgejo.rum.internal";
        SSH_PORT = 2222;
        SSH_LISTEN_PORT = 2222;
        START_SSH_SERVER = true;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      actions = {
        ENABLED = false;
      };
      repository = {
        DEFAULT_BRANCH = "main";
      };
    };
    dump = {
      enable = true;
      interval = "04:31";
      backupDir = "/mnt/raid/backups/forgejo";
    };
  };

  networking.firewall.allowedTCPPorts = [2222];
}
