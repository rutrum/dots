{pkgs, ...}: {
  virtualisation.oci-containers.containers = {
    local-ai = {
      image = "quay.io/go-skynet/local-ai:v3.7.0-gpu-nvidia-cuda-12";
      ports = ["8085:8080"];
      autoStart = true;
      environment = {
      };
      volumes = [
        "models:/models"
      ];
      extraOptions = [
        "--device"
        "nvidia.com/gpu=0"
      ];
    };
  };
}
