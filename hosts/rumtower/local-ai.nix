{...}: {
  virtualisation.oci-containers.containers.local-ai = {
    image = "localai/localai:latest-gpu-nvidia-cuda-13";
    autoStart = true;
    environment = {
      THREADS = "16";
      DEBUG = "false";
      LOCALAI_ADDRESS = ":8089";
    };
    volumes = [
      "/home/rutrum/local-ai/models:/models"
      "/home/rutrum/local-ai/data:/data"
      "/home/rutrum/local-ai/backends:/backends"
    ];
    extraOptions = [
      "--network=host"
      "--device"
      "nvidia.com/gpu=all"
    ];
  };
}
