{
  config,
  pkgs,
  ...
}: let
  # Joplin Server: official container + native PostgreSQL (option 2).
  #
  # Item storage lives in the podman volume `joplin-data` rather than a bind
  # mount. The image runs as its own non-root uid 1001 and owns the paths it
  # writes to (/home/joplin, PM2's /opt/pm2), and podman gives a named volume the
  # ownership of the image directory it covers — so neither a host account, a
  # uid map nor a tmpfiles rule is needed for write access. Borg backs the
  # volume up by path; see hosts/rumnas/borg.nix.
  backVolume = "joplin-data";
  backupDir = "/mnt/raid/backups/joplin";
  serverVersion = "3.7.2"; # keep the minor in lockstep with joplin-desktop
  secrets = config.sops.secrets;
in {
  # joplin.rum.internal -> 127.0.0.1:22300
  services.caddyProxy.services.joplin.port = 22300;

  # Native PostgreSQL: database + role (same pattern as forgejo/firefly).
  # The role gets a password over TCP; the default pg_hba already allows
  # `host all all 127.0.0.1/32 md5`.
  services.postgresql = {
    ensureDatabases = ["joplin"];
    ensureUsers = [
      {
        name = "joplin";
        ensureDBOwnership = true;
      }
    ];
  };

  # Single SOPS field (`joplin/postgres_password`). A template renders it into
  # the KEY=VALUE env file the container consumes.
  sops.secrets."joplin/postgres_password" = {
    owner = "postgres";
  };

  sops.templates."joplin.env" = {
    content = ''
      POSTGRES_PASSWORD=${config.sops.placeholder."joplin/postgres_password"}
    '';
  };

  # Set the role password at activation, after `postgresql-setup` has created
  # the role. Keeps the plaintext out of the world-readable Nix store.
  systemd.services.joplin-db-password = {
    description = "Set the Joplin PostgreSQL role password";
    after = ["postgresql-setup.service"];
    requires = ["postgresql-setup.service"];
    wantedBy = ["multi-user.target"];
    path = [pkgs.coreutils config.services.postgresql.package];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "postgres";
      Group = "postgres";
    };
    # Feed the statement over stdin: psql only performs variable interpolation
    # (`:'pw'`) for input it parses itself, not for a `-c` string. The `\set`
    # backquote form also keeps the password out of psql's argv (`ps`).
    script = ''
      psql -v ON_ERROR_STOP=1 -d postgres <<'SQL'
      \set pw `cat ${secrets."joplin/postgres_password".path}`
      ALTER ROLE joplin WITH PASSWORD :'pw';
      SQL
    '';
  };

  # Joplin Server container. Host networking lets it reach native PostgreSQL on
  # 127.0.0.1; no published ports (Caddy proxies to localhost:22300).
  virtualisation.oci-containers.containers.joplin-server = {
    image = "docker.io/joplin/server:${serverVersion}";
    extraOptions = ["--network=host"];
    environment = {
      # Public HTTPS endpoint served by Caddy with the internal wildcard
      # certificate (joplin.internal.rutrum.net -> localhost:22300). iOS
      # requires HTTPS here, so this must match the URL clients are given.
      APP_BASE_URL = "https://joplin.internal.rutrum.net";
      APP_PORT = "22300";
      DB_CLIENT = "pg";
      POSTGRES_HOST = "127.0.0.1";
      POSTGRES_PORT = "5432";
      POSTGRES_DATABASE = "joplin";
      POSTGRES_USER = "joplin";
      # Joplin rewrites POSTGRES_HOST=127.0.0.1 to `host.docker.internal` whenever
      # RUNNING_IN_DOCKER is truthy (its image sets RUNNING_IN_DOCKER=1), which
      # resolves to the LAN IP where PostgreSQL is not listening. We use host
      # networking, so loopback really is the host: tell Joplin it is not in a
      # container and 127.0.0.1 is used as-is.
      RUNNING_IN_DOCKER = "0";
      STORAGE_DRIVER = "Type=Filesystem; Path=/var/lib/joplin-server/storage";
    };
    environmentFiles = [config.sops.templates."joplin.env".path];
    volumes = ["${backVolume}:/var/lib/joplin-server"];
    autoStart = true;
  };

  # Make sure the role password exists before the container starts.
  systemd.services.podman-joplin-server = {
    after = ["joplin-db-password.service"];
    requires = ["joplin-db-password.service"];
  };

  # Daily logical dump for backups. (Filesystem item storage lives in the
  # podman volume and is backed up from there; see borg.nix.)
  services.postgresqlBackup = {
    enable = true;
    databases = ["joplin"];
    location = backupDir;
    compression = "zstd";
  };
}
