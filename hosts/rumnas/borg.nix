{
  config,
  pkgs,
  ...
}: let
  secrets = config.sops.secrets;
in {
  # Borg system user
  users = {
    users.borg = {
      isSystemUser = true;
      group = "borg";
      home = "/var/lib/borg";
      createHome = true;
      description = "Borg backup service account";
    };
    groups.borg = {};
  };

  # Secrets owned by borg
  sops.secrets."borg/rumnas_borgbase_passphrase".owner = "borg";

  # Backup jobs
  services.borgbackup.jobs = {
    # Local backup: rumnas -> rumtower
    local-rumtower = {
      paths = [
        "/mnt/raid/immich/library"
        "/mnt/raid/immich/upload"
        "/mnt/raid/immich/profile"
        "/mnt/raid/immich/backups"
        "/mnt/raid/homes/rutrum/media/home_video"
      ];
      patterns = ["- **/.direnv"];
      compression = "auto,lzma";
      startAt = []; # Triggered by backup-immich-cooldown
      user = "borg";
      doInit = false;
      repo = "ssh://rutrum@rumtower/mnt/barracuda/backup/immich";
      environment = {
        BORG_RSH = "ssh -i /var/lib/borg/.ssh/id_ed25519";
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      };
      encryption.mode = "none";
    };

    # Cloud backup: rumnas -> BorgBase
    cloud-borgbase = {
      paths = [
        "/mnt/raid/services/paperless"
        "/mnt/raid/services/freshrss"
        "/mnt/raid/immich/library"
        "/mnt/raid/immich/upload"
        "/mnt/raid/immich/profile"
        "/mnt/raid/immich/backups"
      ];
      patterns = ["- **/.direnv"];
      compression = "auto,lzma";
      startAt = "daily";
      user = "borg";
      doInit = false;
      repo = "ssh://jju2y3ar@jju2y3ar.repo.borgbase.com/./repo";
      environment = {
        BORG_RSH = "ssh -i /var/lib/borg/.ssh/id_ed25519";
      };
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${secrets."borg/rumnas_borgbase_passphrase".path}";
      };
    };
  };

  # Grant CAP_DAC_READ_SEARCH to borg backup services
  # This allows the borg user to read all files without needing ACLs
  systemd.services.borgbackup-job-local-rumtower.serviceConfig.AmbientCapabilities = ["CAP_DAC_READ_SEARCH"];
  systemd.services.borgbackup-job-cloud-borgbase.serviceConfig.AmbientCapabilities = ["CAP_DAC_READ_SEARCH"];

  # Wrapper service with 24h cooldown (triggered by rumtower on boot)
  systemd.services.backup-immich-cooldown = {
    description = "Backup Immich to rumtower (with 24h cooldown)";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    path = with pkgs; [coreutils systemd curl];

    script = ''
      STAMP_FILE="/var/lib/backup-stamps/immich-rumtower"
      MIN_INTERVAL=$((24 * 60 * 60))

      mkdir -p "$(dirname "$STAMP_FILE")"

      if [ -f "$STAMP_FILE" ]; then
        LAST=$(cat "$STAMP_FILE")
        NOW=$(date +%s)
        DIFF=$((NOW - LAST))
        if [ $DIFF -lt $MIN_INTERVAL ]; then
          echo "Last backup was $((DIFF / 3600)) hours ago (min: 24h), skipping"
          exit 0
        fi
      fi

      if systemctl start borgbackup-job-local-rumtower.service; then
        date +%s > "$STAMP_FILE"
        echo "Backup completed"
      else
        curl -d "Immich backup to rumtower failed" ntfy.rum.internal/alerts || true
        exit 1
      fi
    '';
  };
}
