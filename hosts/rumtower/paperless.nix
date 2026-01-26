{perSystem, ...}: {
  services.paperless = {
    enable = true;
    package = perSystem.nixpkgs-unstable.paperless-ngx;
    address = "0.0.0.0";
    port = 8000;

    dataDir = "/mnt/barracuda/paperless/data";
    mediaDir = "/mnt/barracuda/paperless/media";
    consumptionDir = "/mnt/barracuda/paperless/consume";

    settings = {
      # Preserve OCR setting for digital signatures
      PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
    };
  };
}
