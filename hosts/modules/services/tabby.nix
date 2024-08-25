{ pkgs, ... }:
{
  #services.tabby = {
  #  enable = true;
  #  port = 11029;
  #  acceleration = "cuda"; # should default to cuda? maybe cpu
  #};
  #networking.firewall.allowedTCPPorts = [ 11029 ];

  #environment.systemPackages = with pkgs; [ cuda

  virtualisation.oci-containers.containers = {
    tabbyml = {
      image = "tabbyml/tabby";
      ports = [ "11029:8080" ];
      volumes = [
        "tabby:/data"
      ];
      environment = {};
      autoStart = true;
      extraOptions = [
        "--gpus" "all"
      ];
      cmd = [
        "serve"
        "--device" "cuda"
        "--model" "StarCoder-3B"
      ];
    };
  };

}
