{
  config,
  pkgs,
  ...
}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "cloud.rutrum.net";

    # Use HTTPS
    https = true;

    # Database configuration - PostgreSQL
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      # adminpassFile is required - create a simple password file
      # You can change the password later via web UI or occ command
      adminpassFile = toString (pkgs.writeText "nextcloud-admin-pass" "CHANGE_ME_ON_FIRST_LOGIN");
    };

    # PHP settings
    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
      "opcache.memory_consumption" = "128";
    };

    # Maximum upload size
    maxUploadSize = "16G";

    # Auto-update apps
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";

    # Enable some useful apps
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts tasks notes;
    };

    settings = {
      # Trust the Caddy reverse proxy
      trusted_proxies = ["127.0.0.1"];
      overwriteprotocol = "https";

      # Performance settings
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
      };

      # Default phone region
      default_phone_region = "US";
    };
  };

  # Redis for Nextcloud caching
  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
  };

  # Nextcloud uses nginx internally, listening on a unix socket by default
  # We need to make nginx listen on a TCP port so Caddy can proxy to it
  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 8080;
      }
    ];
  };

  # Configure Caddy to proxy to nginx
  services.caddy.virtualHosts."cloud.rutrum.net".extraConfig = ''
    reverse_proxy http://127.0.0.1:8080
  '';
}
