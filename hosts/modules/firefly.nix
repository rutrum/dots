{ config, pkgs, ... }:
{
  # create network in systemd
  systemd.services.init-firefly-network = {
    description = "Create network for firefly containers.";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.type = "oneshot";
    script = let
      dockercli = "${config.virtualisation.docker.package}/bin/docker";
    in ''
      check=$(${dockercli} network ls | grep "firefly" || true)
      if [ -z "$check" ]; then
        ${dockercli} network create firefly
      else
        echo "Network 'firefly' already exists."
      fi
    '';
  };

  # the containers
  virtualisation.oci-containers.containers = {
    firefly = {
      image = "fireflyiii/core:latest";
      ports = [ "8080:8080" ];
      volumes = [
        "/mnt/barracuda/firefly/upload:/var/www/html/storage/upload"
      ];
      environment = {};
      dependsOn = [ "firefly-db" ];
      autoStart = true;
      extraOptions = [
        "--network=firefly"
      ];
    };
    firefly-db = {
      image = "library/mariadb:latest"; # official docker images use "library/"
      volumes = [ "/mnt/barracuda/firefly/db:/var/lib/mysql" ];
      autoStart = true;
      extraOptions = [
        "--network=firefly"
      ];
    };
  };
}
