{
  config,
  pkgs,
  ...
}: let
in {
  sops.secrets."nix-serve/secret-key-file".owner = "root";
  services.nix-serve = {
    enable = true;
    port = 9999;
    openFirewall = true;
    secretKeyFile = config.sops.secrets."nix-serve/secret-key-file".path;
  };

  # attic has a lot of open unsolved issues, and hasn't been updated in 7 months
  # I was unable to get this working.  It also has a preference of modifying nix
  # configuration in place, which is real weird given the nature of this project
  #sops.secrets."attic/environmentFile".owner = "root";
  #services.atticd = {
  #  user = "atticd";
  #  enable = true;
  #  environmentFile = config.sops.secrets."attic/environmentFile".path;
  #  settings = {
  #    listen = "0.0.0.0:9999";
  #  };
  #};
  #environment.systemPackages = [
  #  pkgs.attic-client
  #];
}
