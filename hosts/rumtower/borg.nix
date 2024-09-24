{ pkgs, config, ... }: let
  backup_directory = "ssh://rutrum@rumnas/mnt/vault/backups";
  secrets = config.sops.secrets;
  paperless_job = {
    paths = [ 
      "/mnt/barracuda/paperless" 
      "/mnt/barracuda/notes" 
      "/mnt/barracuda/docs" 
      "/mnt/barracuda/calibre" 
    ];
    #environment.BORG_RSH = "ssh -v";
    compression = "auto,lzma";
    startAt = "daily";
    user = "rutrum";
    doInit = false;
  };
in {
  sops.secrets = {
    "borg/paperless_passphrase".owner = "rutrum";
    "borgbase/paperless_passphrase".owner = "rutrum";
  };

  services.borgbackup.jobs.paperless_rumnas = paperless_job // {
    repo = "${backup_directory}/paperless";
    encryption = {
      mode = "repokey";
      passCommand = "cat ${secrets."borg/paperless_passphrase".path}";
    };
  };
  services.borgbackup.jobs.paperless_borgbase = paperless_job // {
    repo = "ssh://r62595uo@r62595uo.repo.borgbase.com/./repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${secrets."borgbase/paperless_passphrase".path}";
    };
  };

  environment.systemPackages = [ pkgs.borgbackup ];
}
