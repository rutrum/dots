{...}: {
  virtualisation.oci-containers.containers.local-ai = {
    # Pin the release tag (not `latest`): oci-containers pulls with
    # policy "missing", so a `latest` tag would never refresh. Bump this tag
    # to upgrade. Consumers reach this via LiteLLM, not directly.
    image = "localai/localai:v4.12.1-gpu-nvidia-cuda-13";
    autoStart = true;
    environment = {
      THREADS = "8";
      DEBUG = "false";
      LOCALAI_ADDRESS = ":8089";
    };
    volumes = [
      # Models and backends are re-downloadable and latency-sensitive, and the
      # RAID is spinning disks — keep them on the NVMe.
      "/home/rutrum/local-ai/models:/models"
      "/home/rutrum/local-ai/backends:/backends"
      # State (skills, voice profiles, collections, traces) stays on the RAID
      # so backups can pick it up later.
      "/mnt/raid/services/local-ai/data:/data"
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
    "d /home/rutrum/local-ai/backends 0755 rutrum users -"
  ];
}
