{perSystem, ...}: {
  services.caddyProxy.services.immich.port = 2283;
  services.caddyProxy.services.kiosk.port = 9019;

  services.immich = {
    enable = true;

    # Immich 2.7.5 is EOL/insecure in release-26.05 (CVE-2026-59258,
    # CVE-2026-82272). Pull 3.x from nixpkgs-unstable until 26.11 ships it.
    # TODO: move to stable on 26.11 release
    package = perSystem.nixpkgs-unstable.immich;

    host = "0.0.0.0";
    port = 2283;
    # openFirewall = true; # Caddy-only: reached via immich.rum.internal
    accelerationDevices = null;

    mediaLocation = "/mnt/raid/immich";
  };

  users.users.immich.extraGroups = ["video" "render"];

  virtualisation.oci-containers.containers = {
    immich-kiosk = {
      image = "ghcr.io/damongolding/immich-kiosk:latest";
      ports = ["127.0.0.1:9019:3000"]; # loopback-only: Caddy proxies to it
      environment = {
        KIOSK_IMMICH_URL = "http://host.containers.internal:2283";
        KIOSK_IMMICH_API_KEY = "F1rt9bxYZu3WIcIHMatbpkNWU9fsmPHwUhDfEY4HRNQ";
      };
      autoStart = true;
    };
  };
}
