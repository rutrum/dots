{
  pkgs,
  config,
  ...
}: let
  backup_directory = "ssh://rutrum@rumnas/mnt/vault/backups";
  secrets = config.sops.secrets;
  cloud_job = {
    paths = [
      "/mnt/barracuda/paperless"
      "/mnt/barracuda/notes"
      "/mnt/barracuda/docs"
      "/mnt/barracuda/calibre"
      "/mnt/barracuda/system_exports"
      "/home/rutrum/repo/shtf"
      "/home/rutrum/Zotero"
    ];
    #environment.BORG_RSH = "ssh -v";
    compression = "auto,lzma";
    startAt = "daily";
    user = "rutrum";
    doInit = false;
  };
in {
  # todo: create a borg user to do all of this

  sops.secrets = {
    "borg/cloud_rumnas_passphrase".owner = "rutrum";
    "borg/cloud_borgbase_passphrase".owner = "rutrum";
  };

  services.borgbackup.jobs.cloud-rumnas =
    cloud_job
    // {
      repo = "${backup_directory}/paperless";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${secrets."borg/cloud_rumnas_passphrase".path}";
      };
    };
  services.borgbackup.jobs.cloud-borgbase =
    cloud_job
    // {
      repo = "ssh://r62595uo@r62595uo.repo.borgbase.com/./repo";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${secrets."borg/cloud_borgbase_passphrase".path}";
      };
    };

  # how to mount:
  # 1. determine latest
  services.borgbackup.jobs = {
    local-rumnas = {
      paths = [
        "/mnt/barracuda/home_media"
      ];
      compression = "auto,lzma";
      startAt = "daily";
      user = "rutrum";
      doInit = true;
      repo = "ssh://rutrum@rumnas/mnt/raid/homes/rutrum/backup";
      encryption.mode = "none";
    };
  };

  environment.systemPackages = [pkgs.borgbackup];
}
