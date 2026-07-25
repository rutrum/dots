{
  config,
  lib,
  pkgs,
  ...
}: let
  calibreLibrary = "/mnt/raid/homes/rutrum/books";
in {
  services.calibre-web = {
    enable = true;
    openFirewall = true;
    listen.ip = "0.0.0.0";
    group = "media";
    options = {
      calibreLibrary = "${calibreLibrary}";
      enableBookUploading = true;
    };
  };

  # Ensure calibre-web can write to the calibre library
  systemd.tmpfiles.settings."10-calibre-library" = {
    "${calibreLibrary}".d = {
      user = "rutrum";
      group = "media";
      mode = "0775";
    };
    "${calibreLibrary}/metadata.db".f = {
      user = "rutrum";
      group = "media";
      mode = "0664";
    };
  };
}
