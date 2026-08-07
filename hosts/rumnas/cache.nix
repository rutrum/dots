{config, ...}: {
  sops.secrets."nix-serve/secret-key-file".owner = "root";
  services.nix-serve = {
    enable = true;
    port = 9999;
    # openFirewall removed: nothing pulls from it remotely; add a caddy vhost if needed
    secretKeyFile = config.sops.secrets."nix-serve/secret-key-file".path;
  };
}
