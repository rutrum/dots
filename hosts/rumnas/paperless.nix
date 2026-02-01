{perSystem, ...}: {
  networking.firewall.allowedTCPPorts = [8000];

  services.paperless = {
    enable = true;
    package = perSystem.nixpkgs-unstable.paperless-ngx;
    address = "0.0.0.0";
    port = 8000;
    dataDir = "/mnt/raid/services/paperless";
    settings = {
      PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
    };
  };
}
