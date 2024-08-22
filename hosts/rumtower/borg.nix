{ pkgs, config, ... }: let
  backup_directory = "ssh://rutrum@rumnas/mnt/vault/backups";
in {
  sops.secrets."borg/paperless_passphrase" = {
    owner = "rutrum"; # make this the original borg owner
    # todo: change ownership of the paperless backup repo to borg user?
    # todo: add borg to users list
  };
  services.borgbackup.jobs.paperless = {
    paths = [ "/mnt/barracuda/paperless" ];
    #environment.BORG_RSH = "ssh -v";
    repo = "${backup_directory}/paperless";
    encryption = {
      mode = "repokey";
      passCommand = "cat ${config.sops.secrets."borg/paperless_passphrase".path}";
    };
    compression = "auto,lzma";
    startAt = "daily";
    user = "rutrum";
    doInit = false;
  };

  environment.systemPackages = [ pkgs.borgbackup ];
}
