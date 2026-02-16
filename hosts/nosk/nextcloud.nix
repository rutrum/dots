{
  config,
  pkgs,
  ...
}: {
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "cloud.rutrum.net";

    # Use HTTPS
    https = true;

    # Database configuration - PostgreSQL
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      # adminpassFile not needed - Nextcloud will generate a password on first setup
      # You can view it in /var/lib/nextcloud/config/config.php
      # Or reset it with: nextcloud-occ user:resetpassword admin
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

  # Add Nextcloud virtual host to Caddy
  services.caddy.virtualHosts."cloud.rutrum.net".extraConfig = ''
    reverse_proxy localhost:${toString config.services.nextcloud.port}
  '';
}
