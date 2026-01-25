{
  config,
  pkgs,
  inputs,
  ...
}: {
  systemd.services = inputs.self.lib.mkPodmanNetwork config "firefly";

  virtualisation.oci-containers.containers = {
    firefly = {
      image = "fireflyiii/core:version-6.4.9";
      ports = ["8080:8080"];
      volumes = [
        "/mnt/barracuda/firefly/upload:/var/www/html/storage/upload"
      ];
      environment = {};
      dependsOn = ["firefly-db"];
      autoStart = true;
      environmentFiles = [
        # TODO: replace with sops
        /home/rutrum/secrets/firefly.env
      ];
      networks = ["firefly"];
    };
    firefly-db = {
      image = "library/mariadb:11.4.7"; # official docker images use "library/"
      volumes = ["/mnt/barracuda/firefly_db:/var/lib/mysql"];
      autoStart = true;
      ports = ["3307:3306"];
      environment = {
        MYSQL_ROOT_PASSWORD = "changeme";
        MYSQL_USER = "firefly";
        MYSQL_PASSWORD = "secret_firefly_password";
        MYSQL_DATABASE = "firefly";
      };
      networks = ["firefly"];
    };
  };
}
