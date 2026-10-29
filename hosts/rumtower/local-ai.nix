{...}: {
  # Standalone LocalAI server on the RTX 4070 (12 GB).
  #
  # This is NOT a P2P worker and NOT part of any swarm. Models served here are
  # published to consumers through the LiteLLM gateway on rumnas
  # (hosts/rumnas/litellm.nix), which is the single OpenAI-compatible endpoint
  # everything talks to. Add/download models with the LocalAI WebUI at
  # http://rumtower.local-ai.rum.internal — they become reachable through
  # LiteLLM as "rumtower/<model-name>" with no further config changes.
  virtualisation.oci-containers.containers.local-ai = {
    # Pin the release tag (not `latest`): oci-containers pulls with
    # policy "missing", so a `latest` tag would never refresh. Bump to upgrade.
    image = "localai/localai:v4.12.1-gpu-nvidia-cuda-13";
    autoStart = true;
    environment = {
      THREADS = "16";
      DEBUG = "false";
      LOCALAI_ADDRESS = ":8089";
    };
    # Model storage on the NVMe (~815 GB free): model loads are
    # latency-sensitive, and the disk has plenty of room now.
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

  systemd.tmpfiles.rules = [
    "d /home/rutrum/local-ai 0755 rutrum users -"
    "d /home/rutrum/local-ai/models 0755 rutrum users -"
    "d /home/rutrum/local-ai/data 0755 rutrum users -"
    "d /home/rutrum/local-ai/backends 0755 rutrum users -"
  ];
}
