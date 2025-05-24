{
  config,
  pkgs,
  ...
}: let
  mount_dir = "/mnt/raid/services/freshrss";
in {
  virtualisation.oci-containers.containers = {
    freshrss = {
      image = "freshrss/freshrss:1.24.1";
      ports = ["8085:80"];
      volumes = [
        "${mount_dir}/data:/var/www/FreshRSS/data"
        "${mount_dir}/extensions:/var/www/FreshRSS/extensions"
      ];
      autoStart = true;
      environment = {
        TZ = "US/Indiana/Indianapolis";
        CRON_MIN = "13,43";

        ADMIN_EMAIL = "dave@rutrum.net";
        ADMIN_PASSWORD = "freshrss";
        ADMIN_API_PASSWORD = "freshrss";
      };
    };
  };
}
