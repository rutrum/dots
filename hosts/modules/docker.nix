{ config, pkgs, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs.docker_25;
    };
    oci-containers.backend = "docker";
  };
}
