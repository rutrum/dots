{
  config,
  pkgs,
  inputs,
  ...
}: {
  systemd.services = inputs.self.lib.mkPodmanNetwork config "paperless";

  # the containers
  virtualisation.oci-containers.containers = {
    paperless = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.20.0";
      ports = ["8000:8000"];
      volumes = [
        "/mnt/barracuda/paperless/data:/usr/src/paperless/data"
        "/mnt/barracuda/paperless/media:/usr/src/paperless/media"
        "/mnt/barracuda/paperless/export:/usr/src/paperless/export"
        "/mnt/barracuda/paperless/consume:/usr/src/paperless/consume"
      ];
      environment = {
        PAPERLESS_REDIS = "redis://paperless-redis:6379";
        # removed digital signatures for OCR
        # see the original version of the document for unmodified version
        PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
      };
      dependsOn = ["paperless-redis"];
      autoStart = true;
      #user = "1000";
      networks = ["paperless"];
    };
    paperless-redis = {
      image = "library/redis:latest"; # official docker images use "library/"
      volumes = ["redisdata:/data"];
      autoStart = true;
      #user = "1000";
      networks = ["paperless"];
    };
  };
}
