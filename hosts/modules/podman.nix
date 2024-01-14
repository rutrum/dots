{ config, pkgs, ... }:
{
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
}
