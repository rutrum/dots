{config, ...}: let
  secrets = config.sops.secrets;
in {
  virtualisation.oci-containers.containers.local-ai = {
    image = "localai/localai:latest-gpu-nvidia-cuda-13";
    autoStart = true;
    cmd = ["worker" "p2p-llama-cpp-rpc"];
    environmentFiles = [
      "${secrets."local-ai/env".path}"
    ];
    extraOptions = [
      "--network=host"
      "--device"
      "nvidia.com/gpu=all"
    ];
  };

  sops.secrets."local-ai/env" = {};
}
