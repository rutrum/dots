{pkgs, ...}: {
  virtualisation.oci-containers.containers = {
    local-ai = {
      image = "localai/localai:latest-gpu-nvidia-cuda-13";
      ports = ["8089:8080"];
      autoStart = true;
      environment = {
        THREADS = "8";
        DEBUG = "false";
      };
      volumes = [
        "/mnt/raid/services/local-ai/models:/models"
        "/mnt/raid/services/local-ai/data:/data"
        "/mnt/raid/services/local-ai/backends:/backends"
      ];
      extraOptions = [
        "--device"
        "nvidia.com/gpu=all"
      ];
    };
  };
}
