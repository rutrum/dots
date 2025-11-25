{ pkgs, ... }:
{
  virtualisation.oci-containers.containers = {
    grist = {
      image = "gristlabs/grist";
      ports = ["8484:8484"];
      volumes = [
        "grist-persist:/persist"
      ];
      environment = {
        
      };
      autoStart = true;
    };
  };
}
