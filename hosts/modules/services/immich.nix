{...}: {
  services.immich = {
    enable = true;
    port = 2283;
    openFirewall = true;
    host = "0.0.0.0";
  };
}
