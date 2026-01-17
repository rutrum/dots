{
  config,
  pkgs,
  ...
}: let
  db-name = "romm";
  db-user = "romm-user";
  db-pass = "12hbefjk3df2jkl3kdf";
  secrets = config.sops.secrets;
in {
  sops.secrets = {
    "romm/env".owner = "root";
  };

  # TODO: test if this works and then integrate
  # systemd.services = lib.mkPodmanNetwork "nocodb";

  systemd.services.init-romm-network = {
    description = "Create network for romm containers.";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig.type = "oneshot";
    script = let
      dockercli = "${config.virtualisation.podman.package}/bin/podman";
    in ''
      check=$(${dockercli} network ls | grep "romm" || true)
      if [ -z "$check" ]; then
        ${dockercli} network create romm
      else
        echo "Network 'romm' already exists."
      fi
    '';
  };

  # the containers
  virtualisation.oci-containers.containers = {
    romm = {
      image = "rommapp/romm:4.5.0";
      ports = ["8087:8080"];
      volumes = [
        "/mnt/raid/homes/rutrum/romm/library:/romm/library"
        "/mnt/raid/homes/rutrum/romm/assets:/romm/assets"
        "/mnt/raid/homes/rutrum/romm/config:/romm/config"
        "romm-resources:/romm/resources"
        "romm-redis:/redis-data"
      ];
      environment = {
        DB_HOST = "romm-db";
        DB_NAME = db-name;
        DB_USER = db-user;
        DB_PASSWD = db-pass;
      };
      environmentFiles = [
        "${secrets."romm/env".path}"
      ];
      dependsOn = ["romm-db"];
      autoStart = true;
      networks = ["romm"];
    };
    romm-db = {
      image = "library/mariadb:12.1.2-ubi"; # official docker images use "library/"
      volumes = ["romm-db:/var/lib/mysql"];
      autoStart = true;
      environment = {
        MARIADB_ROOT_PASSWORD = "password";
        MARIADB_DATABASE = "romm";
        MARIADB_USER = db-user;
        MARIADB_PASSWORD = db-pass;
      };
      networks = ["romm"];
    };
  };
  gameyfin = {
    image = "ghcr.io/gameyfin/gameyfin:2";
    containerName = "gameyfin";
    restart = "unless-stopped";
    ports = ["8088:8080"];
    volumes = [
      #"${toString ./db}:/opt/gameyfin/db"
      #"${toString ./data}:/opt/gameyfin/data"
      #"${toString ./plugindata}:/opt/gameyfin/plugindata"
      #"${toString ./logs}:/opt/gameyfin/logs"
      # Add your library mount(s) here, e.g.:
      #"/mnt/barracuda/roms:/opt/gameyfin/library"
    ];
    environment = {
      # Generate an APP_KEY externally (e.g. `openssl rand -base64 32`)
      APP_KEY = "<your app key here>";
      # Optional:
      # APP_URL = "https://gameyfin.example.com";
      # PUID = "1000";
      # PGID = "1000";
    };
    # If you prefer storing secrets in a file managed by NixOS secrets, reference it like:
    # environmentFiles = [ "${secrets.gameyfin.env.path}" ];
    autoStart = true;
  };
}
