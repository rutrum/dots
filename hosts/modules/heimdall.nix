{ lib, config, ... }:
{
  options.heimdall.port = lib.mkOption {
    type = lib.types.int;
    description = "The port to bound Heimdall to.";
  };

  config.virtualisation.oci-containers = {
    containers = {
      heimdall = {
        image = "linuxserver/heimdall";
        ports = [ "${toString config.heimdall.port}:80" ];
        autoStart = true;
        volumes = [
          "/root/heimdallconfig:/config"
        ];
      };
    };
  };
}
