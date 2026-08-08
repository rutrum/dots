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
      THREADS = "16";
      DEBUG = "false";
      # Host networking: listen directly on host port 8089
      LOCALAI_ADDRESS = ":8089";
      # P2P federated mode — rumtower is a federated node
      LOCALAI_P2P = "true";
      LOCALAI_FEDERATED = "true";
    };
    environmentFiles = [
      config.sops.templates."local-ai.env".path
    ];
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
