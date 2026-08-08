{
  config,
  pkgs,
  ...
}: {
  sops.secrets."local-ai/p2p-token" = {};

  sops.templates."local-ai.env".content = ''
    LOCALAI_P2P_TOKEN=${config.sops.placeholder."local-ai/p2p-token"}
  '';

  virtualisation.oci-containers.containers.local-ai = {
    image = "localai/localai:latest-gpu-nvidia-cuda-13";
    autoStart = true;
    environment = {
      THREADS = "8";
      DEBUG = "false";
      # Host networking: listen directly on host port 8089
      LOCALAI_ADDRESS = ":8089";
      # P2P federated mode — rumnas is the primary entry point
      LOCALAI_P2P = "true";
      LOCALAI_FEDERATED = "true";
      FEDERATED_SERVER = "true";
    };
    environmentFiles = [
      config.sops.templates."local-ai.env".path
    ];
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
