{ pkgs, ... }:
{
  options.dashy.port = lib.mkOption {
    type = lib.types.int;
    description = "The port to bound Dashy to.";
  };

  config.virtualisation.oci-containers = {
    containers = {
      dashy = {
        image = "lissy93/dashy";
        ports = [ "${toString config.dashy.port}:8080" ];
        autoStart = true;
        volumes = [
          "/root/dashy_config.yml:/app/user-data/conf.yml"
        ];
        environment = {
          NODE_ENV = "production";
        };
      };
    };
  };
}
