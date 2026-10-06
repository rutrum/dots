{
  config,
  pkgs,
  ...
}: let
  # Joplin Server: official container + native PostgreSQL (option 2).
  #
  # The image's built-in non-root user is uid/gid 1001 (its Dockerfile adds a
  # `joplin` user on top of a base image where `node` already owns 1000), and
  # that user owns the parts of the image the app writes to (`/home/joplin`,
  # PM2's `/opt/pm2`). We therefore keep the container's own uid and map it onto
  # a dedicated host account with the uid/gid map below, so everything the app
  # writes is owned by `joplin` here — see the map's comment.
  dataDir = "/mnt/raid/services/joplin";
  backupDir = "/mnt/raid/backups/joplin";
  serverVersion = "3.7.2"; # keep the minor in lockstep with joplin-desktop
  # Host ids used for the container's *other* uids. Kept clear of rutrum's
  # rootless subuid range (100000-165535) and of the normal/system ranges.
  usernsBase = 300000;
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

  # The container runs with its own uid/gid 1001 mapped onto this account, so
  # the data dir is owned by `joplin` while the image's internal /home/joplin
  # and /opt/pm2 stay owned by "1001" inside the container. (Running the
  # container as another uid with --user instead would break exactly those
  # paths: PM2's home and the /home/joplin/packages/server/logs directory the
  # app creates at startup both end up unwritable.)
  users.users.joplin = {
    isSystemUser = true;
    uid = 993;
    group = "joplin";
    home = dataDir;
    description = "Joplin Server container user";
  };
  users.groups.joplin = {
    gid = 993;
  };

  systemd.tmpfiles.settings."10-joplin-data" = {
    "${dataDir}".d = {
      user = "joplin";
      group = "joplin";
      mode = "0750";
    };
    "${dataDir}/storage".d = {
      user = "joplin";
      group = "joplin";
      mode = "0750";
    };
  };

  # Joplin Server container. Host networking lets it reach native PostgreSQL on
  # 127.0.0.1; no published ports (Caddy proxies to localhost:22300).
  virtualisation.oci-containers.containers.joplin-server = {
    image = "docker.io/joplin/server:${serverVersion}";
    # Map the image's own uid/gid 1001 (its `joplin` user) to the host joplin
    # account, and everything else to an unused host range. Rootful --uidmap is
    # a direct host<->container mapping, so this needs no /etc/subuid entries.
    # The map has to cover 0-65535 completely: with a partial map podman's
    # idmapped overlay mount fails with "creating overlay mount ... permission
    # denied" (verified on rumnas).
    extraOptions = [
      "--network=host"
      "--uidmap=0:${toString usernsBase}:1001"
      "--uidmap=1001:${toString config.users.users.joplin.uid}:1"
      "--uidmap=1002:${toString (usernsBase + 1002)}:${toString (65536 - 1002)}"
      "--gidmap=0:${toString usernsBase}:1001"
      "--gidmap=1001:${toString config.users.groups.joplin.gid}:1"
      "--gidmap=1002:${toString (usernsBase + 1002)}:${toString (65536 - 1002)}"
    ];
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
    volumes = ["${dataDir}:/var/lib/joplin-server"];
    autoStart = true;
  };

  # Make sure the role password exists before the container starts.
  systemd.services.podman-joplin-server = {
    after = ["joplin-db-password.service"];
    requires = ["joplin-db-password.service"];
  };

  # Daily logical dump for backups. (Filesystem item storage is backed up
  # directly via the data dir.)
  services.postgresqlBackup = {
    enable = true;
    databases = ["joplin"];
    location = backupDir;
    compression = "zstd";
  };
}
