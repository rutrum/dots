{...}: {
  services.caddyProxy.services.immich.port = 2283;
  services.caddyProxy.services.kiosk.port = 9019;

  services.immich = {
    enable = true;

    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    accelerationDevices = null;

    mediaLocation = "/mnt/raid/immich";
  };

  users.users.immich.extraGroups = ["video" "render"];

  virtualisation.oci-containers.containers = {
    immich-kiosk = {
      image = "ghcr.io/damongolding/immich-kiosk:latest";
      ports = ["9019:3000"];
      environment = {
        KIOSK_IMMICH_URL = "http://host.containers.internal:2283";
        KIOSK_IMMICH_API_KEY = "F1rt9bxYZu3WIcIHMatbpkNWU9fsmPHwUhDfEY4HRNQ";
      };
      autoStart = true;
    };
  };
}
