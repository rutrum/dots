{config, ...}: {
  sops.secrets."nix-serve/secret-key-file".owner = "root";
  services.nix-serve = {
    enable = true;
    port = 9999;
    openFirewall = true;
    secretKeyFile = config.sops.secrets."nix-serve/secret-key-file".path;
  };
}
