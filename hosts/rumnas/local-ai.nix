{...}: {
  virtualisation.oci-containers.containers.local-ai = {
    # Pin the release tag (not `latest`): oci-containers pulls with
    # policy "missing", so a `latest` tag would never refresh. Bump this tag
    # to upgrade. Must match hosts/rumtower/local-ai.nix (P2P worker).
    image = "localai/localai:v4.12.1-gpu-nvidia-cuda-13";
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
