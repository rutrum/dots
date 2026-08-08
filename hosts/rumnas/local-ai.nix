{}: {
  virtualisation.oci-containers.containers.local-ai = {
    image = "localai/localai:latest-gpu-nvidia-cuda-13";
    autoStart = true;
    environment = {
      THREADS = "8";
      DEBUG = "false";
      LOCALAI_ADDRESS = ":8089";
      LOCALAI_P2P = "true";
    };
    volumes = [
      "/mnt/raid/services/local-ai/models:/models"
      "/mnt/raid/services/local-ai/data:/data"
      "/mnt/raid/services/local-ai/backends:/backends"
    ];
    extraOptions = [
      "--network=host"
      "--device"
      "nvidia.com/gpu=all"
    ];
  };
}
