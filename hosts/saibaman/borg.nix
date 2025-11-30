{
  pkgs,
  config,
  ...
}: let
  paths = [];
  secrets = config.sops.secrets;
in {
  users = {
    users.borg = {
      isSystemUser = true;
      group = "borg";
    };
    groups.borg = {};
  };

  sops.secrets = {
    "borg/bop/rumnas_passphrase".owner = "borg";
  };

  services.borgbackup.jobs.rumnas = {
    paths = [
      "/mnt/share" # samba share?
    ];
    compression = "auto,lzma";
    startAt = "daily";
    user = "borg";
    doInit = true;
    repo = "ssh://borg@rumnas/mnt/raid/backups/bop";
    encryption = {
      mode = "repokey-blake2";
      passCommand = ''cat ${secrets."borg/bop/rumnas_passphrase".path}'';
    };
  };
}
